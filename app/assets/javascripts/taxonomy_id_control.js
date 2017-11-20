(function($,undefined) {
  function TaxonomyIdControl(node, params) {
    this.node = node;
    this.params = params;

    $.extend(this, params)

    this.inputSciName = $(this.node).find(this.relativeCssSelectorSciName);
    this.inputTaxId = $(this.node).find(this.relativeCssSelectorTaxId);

    this._cacheStorage = params.cachedTaxonomies || {};

    this.attachHandlers();
  };

  var proto = TaxonomyIdControl.prototype;

  proto.attachHandlers = function() {
    
    this.inputTaxId.on('keyup', $.proxy(this.findTaxId, this));
    this.inputTaxId.on('blur', $.proxy(this.findTaxId, this));
    this.inputTaxId.on('keyup', $.proxy(this.onKeyUp, this));

    // When focus on the scientific name, send the focus to the next input, as this input
    // is not editable
    this.inputSciName.attr('readonly', true);
    this.inputSciName.on('focus', $.proxy(this.focusToNextInput, this, this.inputSciName));
  };

  proto.focusToNextInput = function(input) {
    input.closest('td').next().find('input').focus();
  };

  proto.onKeyUp = function(e) {
    if (e.keyCode == 13)  {
      if (this.inputTaxId.next().length == 0) {
        $(this.node).next().find('input')[0].focus();
      } else {
        this.inputTaxId.next().focus();
      }
    }
  };

  proto.validateTaxId = function(taxId) {
    return (taxId.match(/^\d*$/));
  };

  proto.markInputsAs = function(mark) {
    this.inputTaxId.parent().removeClass(this.previousMark);
    this.inputSciName.parent().removeClass(this.previousMark);
    this.previousMark = mark;
    this.inputTaxId.parent().addClass(this.previousMark);
    this.inputSciName.parent().addClass(this.previousMark);
  }

  proto.setScientificName = function(scientificName) {
    this.inputSciName.val(scientificName);
    this.inputSciName.attr('title', scientificName);
  };

  proto.onSuccessFindTaxId = function(data) {
    this.setScientificName(data.scientificName);
    this.markInputsAs('has-success');
  };

  proto.onErrorFindTaxId = function() {
    this.markInputsAs('has-error');
  };

  proto.findTaxId = function() {
    var taxId = this.inputTaxId.val();
    this.inputSciName.val('');    
    if (this.validateTaxId(taxId)) {
      if (taxId.length == 0) {
        return;
      }
      if (typeof this._cacheStorage[taxId] !== 'undefined') {
        return this.onSuccessFindTaxId(this._cacheStorage[taxId]);
      }
      $.ajax({
        url: this.taxonomyServiceUrl+'/'+taxId,
        method: 'GET',
        success: $.proxy(this.onSuccessFindTaxId, this),
        error: $.proxy(this.onErrorFindTaxId, this)
      });      
    } else {
      this.markInputsAs('has-error');
    }
  };

  $(document).ready(function() {
    $(document).trigger('registerComponent.builder', {'TaxonomyIdControl': TaxonomyIdControl});
  });

}(jQuery))