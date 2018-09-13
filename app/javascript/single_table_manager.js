import TooltipsManager from 'tooltips_manager'

(function($, undefined) {

  function SingleTableManager(node, params) {
    this.node = $(node);
    this.params = params;

    this.params._cssNotEmptyTabClass = this.params._cssNotEmptyTabClass || 'bg-info';
    this.params._cssEmptyTabClass = this.params._cssEmptyTabClass || 'bg-warning';
    this.params._cssErrorTabClass = this.params._cssErrorTabClass || 'bg-danger';

    //this.errorCells = {};

    this.form = $('form');
    $(this.form).data('remote', true);
    this._tabs = $('a[data-toggle="tab"]');
    this.currentTab = this._tabs[0];

    this._tabs.each($.proxy(function(e, tab) {
      this.updateTabContentPresenceStatus(tab);
    }, this));

    this.tooltipsManager = new TooltipsManager(this.inputs())

    this.attachHandlers();
  }

  var proto = SingleTableManager.prototype;

  proto.restoreTab = function(e) {
    var currentTab = this.currentTab = $(e.target);
    var data = this.dataForTab(currentTab);

    //this.cleanTooltips();

    this.inputs().each($.proxy(this.restoreInput, this, data));

    this.updateValidations();
  };

  proto.tabLabwareIndex = function(tab) {
    var id = tab.attr('id');
    var matching = id.match(/labware_tab\[([0-9]+)\]/);
    return matching ? matching[1] : null;
  };

  proto.setErrorToTab = function(tab) {
    var labwareIndex = this.tabLabwareIndex($(tab));
    if (this.anyErrorsForLabwareIndex(labwareIndex)) {
      $(tab).addClass(this.params._cssErrorTabClass);
      $(tab).removeClass(this.params._cssNotEmptyTabClass);
    } else {
      $(tab).removeClass(this.params._cssErrorTabClass);
    }
  };

  proto.anyErrorsForLabwareIndex = function(labwareIndex) {
    if (labwareIndex && this.errorCells) {
      var lwe = this.errorCells[labwareIndex];
      if (lwe) {
        for (var i in lwe) {
          if (lwe[i] && !$.isEmptyObject(lwe[i])) {
            return true;
          }
        }
      }
    }
    return false;
  }

  proto.unsetErrorToTab = function(tab) {
    this.setErrorToTab(tab);
    this.updateTabContentPresenceStatus(tab);
  };

  proto.updateTabContentPresenceStatus = function(tab) {
    $(tab).toggleClass(this.params._cssNotEmptyTabClass, !this.isTabEmpty(tab));
    $(tab).toggleClass(this.params._cssEmptyTabClass, this.isTabEmpty(tab));
  };


  proto.isTabEmpty = function(tab) {
    return !this.isTabWithContent(tab);
  }

  proto.isTabWithContent = function(tab) {
    var data = this.dataForTab(tab); // data is the labware for this tab

    return (data["contents"] != null);
    // TODO -- this needs to examine data more closely

    // if (data.content===null) {
    //   return false;
    // }

    // return $.map(data.content)

    // return $.map(data.wells_attributes, function(n){return n;}).some(function(well) {
    //   var biomaterialAttributes = well.biomaterial_attributes;
    //   return ['donor_name', 'gender', 'id', 'phenotype', 'supplier_name', 'uuid', 'common_name'].some(function(name) {
    //     return ((biomaterialAttributes[name]!==null) && (biomaterialAttributes[name]!=''));
    //   });
    // });
  };

  proto.validateInput = function(input, fromUserInteraction) {
    var name = $(input).parents('td').data('psd-schema-validation-name');
    //$(input).parent().removeClass('has-error');

    // It will store in the input that we are interacting with the input, so we can take
    // decissions in future about how to display the potential errors
    $(input).data('fromUserInteraction', fromUserInteraction);
    if (name) {
      $(input).trigger('psd.schema.validation', {
        node: input,
        name: name,
        value: $(input).val()
      });
    }
  };


  proto.saveTab = function(e, leaving) {
    var currentTab = $(e.target);
    var data = this.dataForTab(currentTab);

    this.inputs().each($.proxy(this.saveInput, this, data));

    if (!leaving) {
      var changeTabField = $("<input name='material_submission[change_tab]' value='true' type='hidden' />");
      $(this.form).append(changeTabField);
    }
    var promise = $.post($(this.form).attr('action'), $(this.form).serialize()).then(
      $.proxy(this.onReceive, this, currentTab),
      $.proxy(this.onError, this)
    );

    if (!leaving) {
     changeTabField.remove();
    }
    return promise;
  };

  proto.onSchemaSuccess = function(e, data) {
    $(data.node).parent().removeClass('has-error');
    $(data.node).parent().removeClass('has-warning');
    this.tooltipsManager.cleanTooltip(data.node);
  };

  proto.onSchemaWarning = function(e, data) {
    this.tooltipsManager.loadMessages(data)
    this.tooltipsManager.updateValidations()
  };


  proto.onSchemaError = function(e, data) {
    return this.onReceive($(this.currentTab), data);
  };


  proto.cleanValidLabwares = function(labwareIndexes) {
    if (typeof this.errorCells !== 'undefined') {
      for (var i=0; i<labwareIndexes.length; i++) {
        delete(this.errorCells[labwareIndexes[i]]);
      }
    }
  };

  proto.onReceive = function(currentTab, data, status) {
    if (data.update_successful) {
      this.unsetErrorToTab(currentTab[0]);
      if (data.labwares_indexes) {
        this.cleanValidLabwares(data.labwares_indexes);
      }
    } else {
      this.resetMainAlertError();

      this.tooltipsManager.loadMessages(data);
      this.setErrorToTab(currentTab[0]);
    }
    this.tooltipsManager.updateValidations();
    return data;
  };

  proto.updateValidations = function() {
    //this.cleanTooltips();
    var data = this.dataForTab(this.currentTab)

    this._errorMessagesStore.updateValidations(this.inputs(), data)
    this._warningMessagesStore.updateValidations(this.inputs(), data)
  };


  proto.inputs = function() {
    return $('form input').filter(function(pos, input) {
      return($(input).attr('id') && $(input).attr('id').search(/labware/)>=0);
    });
  };

  proto.notEmptyInputs = function() {
    return $('form input').filter(function(pos, input) {
      return(($(input).val().length > 0) && $(input).attr('id') && $(input).attr('id').search(/labware/)>=0);
    });
  };


  proto.saveInput = function(data, pos, input) {
    if (data == null) {
      return;
    }

    var id = $(input).attr('id');
    var info = this.fieldsForId(id);

    if (info && data.labware_index == info.labwareIndex) {

      // Get and santize the value of the input
      var v = $(input).val();
      if (v != null) {
        v = $.trim(v);
        if (v == '') {
          v = null;
        }
      }
      if (v) {
        if (!data["contents"]) {
          data["contents"] = {}
        }
        if (!data["contents"][info.address]) {
          data["contents"][info.address] = {}
        }
        data["contents"][info.address][info.fieldName] = v;
      } else if (this.fieldData(data, info.address, info.fieldName) != null) {
        data["contents"][info.address][info.fieldName] = null;
      }
    }
  };


  proto.fieldData = function(data, address, fieldName) {
    if (data && data["contents"] && address && data["contents"][address] && fieldName) {
      return data["contents"][address][fieldName];
    }
    return null;
  }

  proto.restoreInput = function(data, pos, input) {
    var id = $(input).attr('id');
    var info = this.fieldsForId(id);

    if (info && data.labware_index==info.labwareIndex) {
      $(input).val(this.fieldData(data, info.address, info.fieldName));
    }
  };

  // This returns the labware object linked to the tab
  proto.dataForTab = function(tab) {
    for (var key in this.params) {
      if ($(tab).attr('href') === ('#Labware' + this.params[key].labware_index)) {
        return this.params[key];
      }
    }
    return null;
  };

  proto.saveCurrentTab = function(e) {
    this.saveTab({target: this.currentTab}, false);
    if (e) {
      e.preventDefault();
    }
  };

  proto.showModal = function(data) {
    $('#alert-modal .modal-title').html(data.title);
    $('#alert-modal .modal-body').html(data.body);
    $('#alert-modal').modal();
  };

  proto.showAlert = function(data) {
    $('#page-error-alert > .alert-title').html(data.title);
    $('#page-error-alert > .alert-msg').html(data.body);
    $('#page-error-alert').toggleClass('hidden', false);
  };

  proto.resetMainAlertError = function() {
    $('#page-error-alert > .alert-msg').html('');
    $('#page-error-alert').toggleClass('hidden', true);
  };


  proto.addErrorToMainAlertError = function(text) {
    $('#page-error-alert > .alert-msg').append(text);
  };

  proto.isEmptyErrorCells = function() {
    return (Object.keys(this.errorCells).length == 0);
  };

  proto.saveCurrentTabBeforeLeaving = function(button, e) {
    e.stopPropagation();
    e.preventDefault();

    //this.saveTab({target: this.currentTab});
    var promise = this.saveTab({target: this.currentTab}, true);
    if (promise === null) {
      return;
    }
    promise.then($.proxy(function(data) {
      if (data.update_successful && (this.isEmptyErrorCells())) {
        window.location.href = $(button).attr('href');
      } else {
        this.showAlert({
          title: 'Validation problems',
          body: 'Please review and solve the validation problems before continuing'});
        this.setErrorToTab(this.currentTab);
        if (!data.update_successful) {
          this.tooltipsManager.loadMessages(data)
          //this.loadErrorsFromMsg(data, false);
        }
        this.updateValidations();
      }
    }, this), $.proxy(this.onError, this));
  };

  proto.onError = function(e) {
    this.showAlert({
      title: 'Validation Error',
      body: 'We could not save the current content due to an error'
    });
  };

  proto.toNextStep = function(e) {
    this.nextStepUrl = window.location.href.replace('provenance', 'ethics');
    window.location.href = this.nextStepUrl;
  };

  proto.attachHandlers = function() {
    $('a[data-toggle="tab"]').on('hide.bs.tab', $.proxy(this.saveTab, this));
    $('a[data-toggle="tab"]').on('show.bs.tab', $.proxy(this.restoreTab, this));
    $('table tbody tr td input').on('blur', $.proxy(function(e) {
      // This is a validation triggered by a user interaction, so we want to display a tooltip for it
      return this.validateInput(e.target, true);
    }, this));
    $('form').on('submit.rails', $.proxy(this.saveTab, this));

    // If you have one
    var button = $('.save');
    button.on('click', $.proxy(this.saveCurrentTabBeforeLeaving, this, button));
    $(this.node).on('psd.schema.success', $.proxy(this.onSchemaSuccess, this));
    $(this.node).on('psd.schema.error', $.proxy(this.onSchemaError, this));
    $(this.node).on('psd.schema.warning', $.proxy(this.onSchemaWarning, this));

    $('input[type=submit]').on('click', $.proxy(this.toNextStep, this));
  };

  $(document).ready(function() {
    $(document).trigger('registerComponent.builder', {'SingleTableManager': SingleTableManager});
  });

}(jQuery))
