(function($, undefined) {

  function SingleTableManager(node, params) {
    this.node = $(node);
    this.params = params;

    this.params._cssNotEmptyTabClass = this.params._cssNotEmptyTabClass || 'bg-info';
    this.params._cssEmptyTabClass = this.params._cssEmptyTabClass || 'bg-warning';
    this.params._cssErrorTabClass = this.params._cssErrorTabClass || 'bg-danger';

    this._tabsWithError = [];
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

    var barcode = $(e.target).attr('href').replace('#', '');
    $('form td:first-child').html(barcode);
    this.inputs().each($.proxy(this.restoreInput, this, data));

    this.updateValidations();
    //this.inputs().each($.proxy(this.updateErrorInput, this, data));
  };

  proto.updateErrorState = function(input, labwareId, wellId, fieldName) {
    if (this.errorCells[labwareId] && this.errorCells[labwareId][wellId] &&
      this.errorCells[labwareId][wellId][fieldName]) {
      var msg = this.errorCells[labwareId][wellId][fieldName]
      this.setErrorToInput(input, msg);
    }
  };

  proto.setErrorToTab = function(tab) {
    this._tabsWithError.push(tab);
    $(tab).addClass(this.params._cssErrorTabClass);
    $(tab).removeClass(this.params._cssNotEmptyTabClass);
  };

  proto.unsetErrorToTab = function(tab) {
    var index = this._tabsWithError.indexOf(tab);
    if (index > -1) {
      this._tabsWithError.splice(index, 1);
    }

    $(tab).removeClass(this.params._cssErrorTabClass);

    this.updateTabContentPresenceStatus(tab);
  };

  proto.updateTabContentPresenceStatus = function(tab) {
    $(tab).toggleClass(this.params._cssNotEmptyTabClass, !this.isTabEmpty(tab));
    $(tab).toggleClass(this.params._cssEmptyTabClass, this.isTabEmpty(tab));
  };

  proto.setErrorToInput = function(input, msg) {
    var tooltip = $(input).parent().tooltip({
      title: msg,
      container: 'body'
    });
    $(input).parent().tooltip('show');
    $(input).parent().addClass('has-error');
    this.tooltipInputs.push($(input).parent());
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

  proto.cellNameFromErrorKey = function(wellId, key) {
    var fieldName = key.replace(/.*\./, '');
    var name = [
      "material_submission[labwares_attributes][0][wells_attributes][",
      wellId, "][biomaterial_attributes][", fieldName,"]"].join('');
    return(name);
  };

  proto.isTabEmpty = function(tab) {
    return !this.isTabWithContent(tab);
  }

  proto.isTabWithContent = function(tab) {
    var data = this.dataForTab(tab);
    return $.map(data.wells_attributes, function(n){return n;}).some(function(well) {
      var biomaterialAttributes = well.biomaterial_attributes;
      return ['donor_name', 'gender', 'id', 'phenotype', 'supplier_name', 'uuid', 'common_name'].some(function(name) {
        return ((biomaterialAttributes[name]!==null) && (biomaterialAttributes[name]!=''));
      });
    });
  };

  proto.validateInput = function(input) {
    var name = $(input).parents('td').data('psd-schema-validation-name');
    if (!!name) {
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

  proto.saveTab = function(e) {
    var currentTab = $(e.target);
    var data = this.dataForTab(currentTab);

    this.inputs().each($.proxy(this.saveInput, this, data));
    //this.validateTab(currentTab);
      // var input = $("<input name='material_submission[change_tab]' value='true' type='hidden' />");
      // $(this.form).append(input);
      var promise = $.post($(this.form).attr('action'),  $(this.form).serialize()).then(
        $.proxy(this.onReceive, this, currentTab),
        $.proxy(this.onError, this));
      // input.remove();
      return promise;      
    return null;
  };

  proto.onSchemaError = function(e, data) {
    this._tabsWithError=[];
    return this.onReceive($(this.currentTab), data);
    this.loadErrorsFromMsg(data);
    this.updateValidations();
  };

  proto.loadErrorsFromMsg = function(data) {
    for (var i=0; i<data.messages.length; i++) {
      var message = data.messages[i];
      this.resetCellNameErrors(message.labware_id);
    }      

    for (var i=0; i<data.messages.length; i++) {
      var message = data.messages[i];
      var wellId = message.well_id;
      this.storeCellNameError(message.labware_id, wellId, message.errors);
    }

  };

  proto.cleanValidLabwares = function(uuids) {
    if (typeof this.errorCells !== 'undefined') {
      for (var i=0; i<uuids.length; i++) {
        delete(this.errorCells[uuids[i]]);
      }      
    }
  };

  proto.onReceive = function(currentTab, data, status) {
    if (data.update_successful) {
      if (typeof data.labwares_uuids !== 'undefined') {
        this.cleanValidLabwares(data.labwares_uuids);
      }
      this.unsetErrorToTab(currentTab[0]);
    } else {
      this.setErrorToTab(currentTab[0]);
      this.loadErrorsFromMsg(data);
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

  proto.storeCellNameError = function(labwareId, wellId, errors) {
    if (typeof this.errorCells[labwareId]==='undefined') {
      this.resetCellNameErrors(labwareId);
    }
    if (typeof this.errorCells[labwareId][wellId]==='undefined') {
      this.errorCells[labwareId][wellId]={};
    }
    if (typeof errors.schema !== 'undefined') {
      /** Json schema error message from the server json-schema gem */
      for (var i=0; i<errors.schema[0].length; i++) {
        var obj = errors.schema[0][i].message;
        var fieldName = obj.fragment.replace(/#\//, '')
        var text = obj.message;
        this.errorCells[labwareId][wellId][fieldName]=text;
      }
    } else {
      /** Json Schema error message from the JS client */
      for (var key in errors) {
        var fieldName = key.replace(/.*\./, '');
        this.errorCells[labwareId][wellId][fieldName]=errors[key];
      }
    }
  };

  proto.resetCellNameErrors = function(labwareId) {
    this.errorCells[labwareId]={};
  };

  proto.inputs = function() {
    return $('form input').filter(function(pos, input) {
      return($(input).attr('name') && $(input).attr('name').search(/material_submission/)>=0);
    });
  };

  proto.notEmptyInputs = function() {
    return $('form input').filter(function(pos, input) {
      return(($(input).val().length > 0) && $(input).attr('name') && $(input).attr('name').search(/material_submission/)>=0);
    });
  };

  proto.rowNumForName = function(name) {
    var matching = name.match(/\[wells_attributes\]\[(\d*)\]/);
    if (matching) {
      return matching[1]
    } else {
      return null;
    }
  };

  proto.fieldNameForName = function(name) {
    var matching = name.match(/\[biomaterial_attributes\]\[(\w*)\]/);
    if (matching) {
      return matching[1];
    } else {
      return null;
    }
  };

  proto.is_well_attribute_id = function(input) {
    var name = $(input).attr('name');
    return (name.search(/material_submission\[labwares_attributes\]\[0\]\[wells_attributes\]\[\d*\]\[id\]/) >=0);
  };

  proto.is_labware_id = function(input) {
    var name = $(input).attr('name');
    return (name.search(/material_submission\[labwares_attributes\]\[0\]\[uuid\]/) >= 0);
  };

  proto.saveInput = function(data, pos, input) {
    var name = $(input).attr('name');
    var rowNum = this.rowNumForName(name);
    var fieldName = this.fieldNameForName(name);

    if (data===null) {
      return;
    }

    if ((rowNum!==null) && (fieldName!==null)) {
      data.wells_attributes[rowNum].biomaterial_attributes[fieldName] = $(input).val();
    }
  };

  proto.updateErrorInput = function(data, pos, input) {
    var name = $(input).attr('name');
    var rowNum = this.rowNumForName(name)
    var fieldName = this.fieldNameForName(name)

    if (fieldName) {
      this.updateErrorState(input, data.id, data.wells_attributes[rowNum].position, fieldName);
    }
  };

  proto.restoreInput = function(data, pos, input) {
    var name = $(input).attr('name');
    var rowNum = this.rowNumForName(name)
    var fieldName = this.fieldNameForName(name)

    if ((rowNum!==null) && (fieldName!==null)) {
      $(input).val(data.wells_attributes[rowNum].biomaterial_attributes[fieldName]);
    } else {
      if (this.is_well_attribute_id(input)) {
        $(input).val(data.wells_attributes[rowNum].id);
      }
      if (this.is_labware_id(input)) {
        $(input).val(data.id);
      }
    }
  };

  proto.dataForTab = function(tab) {
    for (var key in this.params) {
      if ($(tab).attr('href') == ('#'+this.params[key].barcode)) {
        return this.params[key];
      }
    }
    return null;
  };

  proto.saveCurrentTab = function(e) {
    this.saveTab({target: this.currentTab});
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
    $('.alert .alert-title').html(data.title);
    $('.alert .alert-msg').html(data.body);
    $('.alert').toggleClass('hidden', false);
  };  

  proto.isEmptyErrorCells = function() {
    return (Object.keys(this.errorCells).length == 0);
  };

  proto.saveCurrentTabBeforeLeaving = function(button, e) {
    e.stopPropagation();
    e.preventDefault();

    //this.saveTab({target: this.currentTab});
    var promise = this.saveTab({target: this.currentTab});
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
          this.loadErrorsFromMsg(errorMsgs);
        }
        this.updateValidations();
      }
    }, this), $.proxy(this.onError, this));
  };

  proto.onError = function(e) {
    this.showAlert({
      title: 'Validation Error',
      body: 'We could not save the current content due to an error'})
  };

  proto.toDispatch = function(e) {
    this.dispatchUrl = window.location.href.replace('provenance', 'dispatch');
    window.location.href = this.dispatchUrl;
  };

  proto.attachHandlers = function() {
    $('a[data-toggle="tab"]').on('hide.bs.tab', $.proxy(this.saveTab, this));
    $('a[data-toggle="tab"]').on('show.bs.tab', $.proxy(this.restoreTab, this));
    //$('table tbody tr td input').on('blur', $.proxy(this.saveCurrentTab, this));
    $('table tbody tr td input').on('blur', $.proxy(function(e) {
      return this.validateInput(e.target);
    }, this));
    $('form').on('submit.rails', $.proxy(this.saveTab, this));

    // If you have one
    var button = $('.save');
    button.on('click', $.proxy(this.saveCurrentTabBeforeLeaving, this, button));

    $(this.node).on('psd.schema.error', $.proxy(this.onSchemaError, this));

    $('input[type=submit]').on('click', $.proxy(this.toDispatch, this));
  };

  $(document).ready(function() {
    $(document).trigger('registerComponent.builder', {'SingleTableManager': SingleTableManager});
  });


}(jQuery))
