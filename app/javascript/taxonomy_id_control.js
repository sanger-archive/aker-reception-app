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

    this.numAjaxCalls = 0;
    this.lastStoredCall = (-1);

    this.attachHandlers();
  };

  var proto = TaxonomyIdControl.prototype;

  proto.attachHandlers = function() {
    $(this.node).closest('table').on('psd.update-table', $.proxy(this.onUpdateTable, this));
    this.inputTaxId.on('keyup', $.proxy(this.findTaxId, this, false));
    this.inputTaxId.on('change', $.proxy(this.findTaxId, this, false));
    this.inputTaxId.on('blur', $.proxy(this.findTaxId, this, false));
    this.inputTaxId.on('keyup', $.proxy(this.onKeyUp, this, false));

    // When focus on the scientific name, send the focus to the next input, as this input
    // is not editable
    this.inputSciName.attr('readonly', true);
    this.inputSciName.on('focus', $.proxy(this.focusToNextInput, this, this.inputSciName));
  };

  proto.manifestWithScientificNameWarning = function() {
    if (this.getScientificName().length > 0) {
      ManifestCSVWarnings.addWarning("sciname-taxon");
    }
  };

  proto.manifestWithDifferentValueForScientificNameInputWarning = function() {
    var previousValue = this.getScientificName();
    this.findTaxId(true);
    var actualValue = this.getScientificName();
    if ((previousValue.length > 0) && (previousValue != actualValue)) {
      this.markInputsAs('has-warning');
    }
  };

  proto.onUpdateTable = function() {
    this.manifestWithScientificNameWarning();
    this.manifestWithDifferentValueForScientificNameInputWarning();
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
    this.toggleMark(this.previousMark, false);
    this.toggleMark(this.previousMark, false);

    this.previousMark = mark;

    this.toggleMark(this.previousMark, true);
    this.toggleMark(this.previousMark, true);
  }

  proto.toggleMark = function(mark, toggle) {
    this.inputTaxId.parent().toggleClass(this.previousMark, toggle);
    this.inputSciName.parent().toggleClass(this.previousMark, toggle);
  };

  proto.setScientificName = function(scientificName) {
    this.inputSciName.attr('value', scientificName);
    this.inputSciName.val(scientificName);
    this.inputSciName.attr('title', scientificName);
    this.inputSciName.trigger('change');
  };

  proto.getScientificName = function() {
    return this.inputSciName.val();
  };

  proto.getTaxonId = function() {
    return this.inputTaxId.val();
  };

  /**
  * There is a chance that the response of the Ajax calls come back in a different order to the one they were
  * emited to the server, leaving with an inconsistent value from what the user typed. This method ensures that
  * we will ignore any ajax response that is older than the last one we have used to update the interface.
  **/
  proto.executeHandlerOnlyIfNewerCall = function(handler, numCall) {
    var restArguments = Array.prototype.splice.call(arguments, 2);
    if (numCall > this.lastStoredCall) {
      this.lastStoredCall = numCall;
      return handler.apply(this, restArguments);
    }
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
    var taxId = this.getTaxonId();
    this.setScientificName('');
    if (this.validateTaxId(taxId)) {
      if (taxId.length == 0) {
        this.toggleMark('has-success', false);
        this.toggleMark('has-error', false);
        return;
      }
      if (typeof this._cacheStorage[taxId] !== 'undefined') {
        return this.onSuccessFindTaxId(this._cacheStorage[taxId]);
      }

      this.numAjaxCalls += 1;
      $.ajax({
        url: this.taxonomyServiceUrl+'/'+taxId,
        method: 'GET',
        success: $.proxy(this.executeHandlerOnlyIfNewerCall, this, this.onSuccessFindTaxId, this.numAjaxCalls),
        error: $.proxy(this.executeHandlerOnlyIfNewerCall, this, this.onErrorFindTaxId, this.numAjaxCalls),
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
