(function($, undefined) {
  function SingleTableManager(node, params) {
    this.node = $(node);
    this.params = params;

    this.errorCells = {};
    this.tooltipInputs = [];

    this.form = $('form');
    $(this.form).data('remote', true);
    this.currentTab = $('a[data-toggle="tab"]')[0];

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

  proto.saveTab = function(e) {
    var currentTab = $(e.target);
    var data = this.dataForTab(currentTab);

    this.inputs().each($.proxy(this.saveInput, this, data));

    var input = $("<input name='material_submission[change_tab]' value='true' type='hidden' />");
    $(this.form).append(input);

    $.post($(this.form).attr('action'),  $(this.form).serialize()).then(
      $.proxy(this.onReceive, this),
      $.proxy(this.onError, this));
    input.remove();
  };

  proto.onReceive = function(data, status) {
    if (data.update_successful) {
      this.errorCells = {};
    } else {
      for (var i=0; i<data.messages.length; i++) {
        var message = data.messages[i];
        this.resetCellNameErrors(message.labware_id);
      }
      for (var i=0; i<data.messages.length; i++) {
        var message = data.messages[i];
        var wellId = message.well_id;
        this.storeCellNameError(message.labware_id, wellId, message.errors);
      }
    }
    this.updateValidations();
  };

  proto.updateValidations = function() {
    this.cleanTooltips();
    this.inputs().each($.proxy(this.updateErrorInput, this, this.dataForTab(this.currentTab)));
  };

  proto.storeCellNameError = function(labwareId, wellId, errors) {
    if (typeof this.errorCells[labwareId]==='undefined') {
      this.resetCellNameErrors(labwareId);
    }
    if (typeof this.errorCells[labwareId][wellId]==='undefined') {
      this.errorCells[labwareId][wellId]={};
    }
    for (var key in errors) {
      var fieldName = key.replace(/.*\./, '');
      this.errorCells[labwareId][wellId][fieldName]=errors[key];
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
    return (name.search(/material_submission\[labwares_attributes\]\[0\]\[id\]/) >= 0);
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
      this.updateErrorState(input, data.id, data.wells_attributes[rowNum].id, fieldName);
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
      if ($(tab).attr('href') == ('#'+this.params[key].barcode.value)) {
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

  proto.toDispatch = function(e) {
    this.dispatchUrl = window.location.href.replace('provenance', 'dispatch');
    window.location.href = this.dispatchUrl;
  };

  proto.attachHandlers = function() {
    $('a[data-toggle="tab"]').on('hide.bs.tab', $.proxy(this.saveTab, this));
    $('a[data-toggle="tab"]').on('show.bs.tab', $.proxy(this.restoreTab, this));
    //$('table tbody tr td input').on('blur', $.proxy(this.saveCurrentTab, this));
    $('form').on('submit.rails', $.proxy(this.saveTab, this));
    $('button.save').on('click', $.proxy(this.saveCurrentTab, this));

    $('input[type=submit]').on('click', $.proxy(this.toDispatch, this));
  };

  $(document).ready(function() {
    $(document).trigger('registerComponent.builder', {'SingleTableManager': SingleTableManager});
  });


}(jQuery))
