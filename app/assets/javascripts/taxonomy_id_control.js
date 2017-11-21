(function($,undefined) {
  function TaxonomyIdControl(node, params) {
    this.node = node;
    this.params = params;

    $.extend(this, params)

    this.inputSciName = $(this.node).find(this.relativeCssSelectorSciName);
    this.inputTaxId = $(this.node).find(this.relativeCssSelectorTaxId);

    if (typeof window._taxonomyCache == 'undefined') {
      window._taxonomyCache = {};
    }
    window._taxonomyCache = $.extend(window._taxonomyCache, params.cachedTaxonomies);
    this._cacheStorage = window._taxonomyCache;

    this.attachHandlers();
  };

  var proto = TaxonomyIdControl.prototype;

  proto.attachHandlers = function() {
    $(this.node).closest('table').on('psd.update-table', $.proxy(this.findTaxId, this, true));
    this.inputTaxId.on('keyup', $.proxy(this.findTaxId, this, false));
    this.inputTaxId.on('change', $.proxy(this.findTaxId, this, false));
    this.inputTaxId.on('blur', $.proxy(this.findTaxId, this, false));
    this.inputTaxId.on('keyup', $.proxy(this.onKeyUp, this, false));

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
    this._cacheStorage[data.taxId] = data;
    this.setScientificName(data.scientificName);
    this.markInputsAs('has-success');
  };

  proto.onErrorFindTaxId = function() {
    this.markInputsAs('has-error');
  };

  proto.findTaxId = function(synchronous) {
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
        error: $.proxy(this.onErrorFindTaxId, this),
        async: !synchronous
      });      
    } else {
      this.markInputsAs('has-error');
    }
  };

  $(document).ready(function() {
    $(document).trigger('registerComponent.builder', {'TaxonomyIdControl': TaxonomyIdControl});
  });

}(jQuery))