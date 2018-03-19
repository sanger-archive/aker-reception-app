(function($, undefined) {

  function SingleTableManager(node, params) {
    this.node = $(node);
    this.params = params;

    this.params._cssNotEmptyTabClass = this.params._cssNotEmptyTabClass || 'bg-info';
    this.params._cssEmptyTabClass = this.params._cssEmptyTabClass || 'bg-warning';
    this.params._cssErrorTabClass = this.params._cssErrorTabClass || 'bg-danger';

    this.errorCells = {};
    this.tooltipInputs = [];

    this.form = $('form');
    $(this.form).data('remote', true);
    this._tabs = $('a[data-toggle="tab"]');
    this.currentTab = this._tabs[0];

    this._tabs.each($.proxy(function(e, tab) {
      this.updateTabContentPresenceStatus(tab);
    }, this));

    this.attachHandlers();
  }

  var proto = SingleTableManager.prototype;

  proto.restoreTab = function(e) {
    var currentTab = this.currentTab = $(e.target);
    var data = this.dataForTab(currentTab);

    this.cleanTooltips();

    this.inputs().each($.proxy(this.restoreInput, this, data));

    this.updateValidations();
  };

  proto.updateErrorState = function(input, labwareIndex, address, fieldName) {
    if (this.errorCells[labwareIndex] && this.errorCells[labwareIndex][address]
        && this.errorCells[labwareIndex][address][fieldName]) {
      this.setErrorToInput(input, this.errorCells[labwareIndex][address][fieldName]);
    }
  };

  proto.tabLabwareIndex = function(tab) {
    var id = tab.attr('id');
    var matching = id.match(/labware_tab\[([0-9]+)\]/);
    return matching ? matching[1] : null;
  }

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

  proto.setErrorToInput = function(input, msg) {
    // If the error has been generated from a user interaction, it will display a tooltip
    if ($(input).data('fromUserInteraction') === true) {
      var tooltip = $(input).parent().tooltip({
        title: msg,
        container: 'body'
      });
      $(input).parent().tooltip('show');
      this.tooltipInputs.push($(input).parent());
    }

    $(input).data('fromUserInteraction', false);
    $(input).parent().addClass('has-error');
  };

  proto.cleanTooltips = function() {
    for (var i=0; i<this.tooltipInputs.length; i++) {
      $(this.tooltipInputs[i]).tooltip('hide');
      $(this.tooltipInputs[i]).tooltip('disable');
      $(this.tooltipInputs[i]).tooltip('destroy');
      setTimeout($.proxy(function() {
        $(this.tooltipInputs[i]).tooltip('destroy');
      }, this), 0);
      $(this.tooltipInputs[i]).removeClass('has-error');

    }
    this.tooltipInputs=[];
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
    $(input).parent().removeClass('has-error');
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

  proto.validateNotEmptyInputs = function(tab) {
    this.notEmptyInputs().each($.proxy(function(pos, input) {
      return this.validateInput(input);
    }, this));
  };

  proto.validateTab = function(tab) {
    this.inputs().each($.proxy(function(pos, input) {
      return this.validateInput(input);
    }, this));
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

  proto.onSchemaError = function(e, data) {
    return this.onReceive($(this.currentTab), data);
  };

  proto.loadErrorsFromMsg = function(data, clearErrors) {
    if (data && data.messages) {

      for (var key in data) {
        for (var i = 0; i < data.messages.length; i++) {
          var message = data.messages[i];
          this.resetCellNameErrors(message.labwareIndex);
        }
        if (clearErrors) this.resetMainAlertError();

        for (var i = 0; i<data.messages.length; i++) {
          var message = data.messages[i];
          var address = message.address;
          if (address) {
            this.storeCellNameError(message.labwareIndex, address, message.errors);
          } else {
            this.addErrorToMainAlertError('<li>Labware '+message.labwareIndex+', errors: '+Object.values(message.errors)[0]+"</li>");
            var tab = document.getElementById("labware_tab["+message.labwareIndex+"]");
            this.setErrorToTab(tab);
          }
        }
      }
    }
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
      this.loadErrorsFromMsg(data, true);
      this.setErrorToTab(currentTab[0]);
    }
    this.updateValidations();
    return data;
  };

  proto.updateValidations = function() {
    this.cleanTooltips();
    setTimeout($.proxy(function() {
      this.inputs().each($.proxy(this.updateErrorInput, this, this.dataForTab(this.currentTab)));
    }, this), 500);
  };

  proto.storeCellNameError = function(labwareIndex, address, errors) {
    if (!this.errorCells[labwareIndex]) {
      this.resetCellNameErrors(labwareIndex);
    }
    if (!this.errorCells[labwareIndex][address]) {
      this.errorCells[labwareIndex][address]={};
    }
    if (errors.schema) {
      /** Json schema error message from the server json-schema gem */
      for (var i=0; i<errors.schema[0].length; i++) {
        var obj = errors.schema[0][i].message;
        var fieldName = obj.fragment.replace(/#\//, '')
        var text = obj.message;
        this.errorCells[labwareIndex][address][fieldName] = text;
      }
    } else {
      /** Json Schema error message from the JS client */
      for (var key in errors) {
        var fieldName = key.replace(/.*\./, '');
        this.errorCells[labwareIndex][address][fieldName] = errors[key];
      }
    }
  };

  proto.resetCellNameErrors = function(labwareIndex) {
    this.errorCells[labwareIndex]={};
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

  /**
   * Returns the fields from the cell of the given ID
   */
  proto.fieldsForId = function(id) {
    var matching = id.match(/labware\[([0-9]*)\]address\[([A-Z0-9:]*)\]fieldName\[(\w*)\]/);
    if (matching) {
      return {
        "labwareIndex": matching[1],
        "address": matching[2],
        "fieldName": matching[3]
      };
    }
    return null;
  }

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

  proto.updateErrorInput = function(data, pos, input) {
    var id = $(input).attr('id');
    var info = this.fieldsForId(id);

    if (info) {
      this.updateErrorState(input, info.labwareIndex, info.address, info.fieldName);
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
          this.loadErrorsFromMsg(data, false);
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
    $(this.node).on('psd.schema.error', $.proxy(this.onSchemaError, this));

    $('input[type=submit]').on('click', $.proxy(this.toNextStep, this));
  };

  $(document).ready(function() {
    $(document).trigger('registerComponent.builder', {'SingleTableManager': SingleTableManager});
  });


}(jQuery))
