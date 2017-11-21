(function($,undefined) {
  function TaxonomyControl(node, params) {
    this.node = node;
    this.params = params;

    this._nodeTaxIdInput = $(this.node).closest('tr').find('td[data-psd-schema-validation-name=tax_id] input');

    this.attachHandlers();
  }

  window.TaxonomyControl = TaxonomyControl;

  var proto = TaxonomyControl.prototype;

  proto.emptyPadding = function(str, num) {
    var spaces = num - str.toString().length;
    if (spaces > 0) {
      var list = [];
      for (var i=0; i< spaces; i++) {
        list.push("<span style='visibility:hidden;'>_</span>");
      }
      return list.join('');
    }
    return str;
  };


  proto.renderResult = function(elem) {
    if (!elem.id) {
      return elem.text;
    }
    var $state = $(
      JST['templates/result_scientific_name'](Object.assign(elem, { emptyPadding: this.emptyPadding}))
    );
    return $state;
  };

  proto.renderSelection = function(elem) {
    if (!elem.id) {
      return elem.text;
    }
    var $state = $(
      JST['templates/selection_scientific_name'](Object.assign(elem, { emptyPadding: this.emptyPadding}))
    );
    return $state;
  };  

  proto.buildSelect = function() {
    return $(this.node).select2({
      placeholder: 'No selection',
      templateSelection: $.proxy(this.renderSelection, this),
      templateResult: $.proxy(this.renderResult, this),
      allowClear: true,
      theme: "bootstrap",
      minimumInputLength: 3,
      ajax: {
        //data: function() { return {}; },
        cache: true,
        processResults: function(data, params) {
          params.page = params.page || 1;
          return {
            results: $.map(data, function(o) { 
              return Object.assign({
                id: o.scientificName,
                text: o.scientificName
              }, o);
            })
          }
        },
        dataType: 'json',
        url: function (params) {
          return 'https://www.ebi.ac.uk/ena/data/taxonomy/v1/taxon/suggest-for-search/' + params.term;
        }
      }
    });
  };

  proto.addSelectionToRememberList = function(selection) {
    if (typeof proto.REMEMBER_SELECTION_LIST === 'undefined') {
      proto.REMEMBER_SELECTION_LIST = [];
    }
    proto.REMEMBER_SELECTION_LIST.push(selection);
  };

  proto.onSelect = function(event) {
    var selection = event.params.data;
    this._nodeTaxIdInput.val(selection.taxId);
    this.addSelectionToRememberList(selection);
  };

  proto.selectRememberedOption = function(node) {
    this._select.trigger({
      type: 'select2:select',
      params: {
        data: node
      }
    });

    //this._select.trigger('select2:select', {params: node });
  }

  proto.renderRememberSelectionList = function() {
    var list = [];
    $(proto.REMEMBER_SELECTION_LIST).each($.proxy(function(pos, node) {
      var $dom = $(this.renderResult(node));
      $dom.on('click', $.proxy(this.selectRememberedOption, this, node));
      list.push($dom);
    }, this));

    return $("<div class='row'><h4>Or select one of the previously selected:</h4></div>").append(list);
  };

  proto.onOpen = function(event) {
    if (typeof proto.REMEMBER_SELECTION_LIST != 'undefined') {
      //this.selectRememberedOption(proto.REMEMBER_SELECTION_LIST[0]);
      var selection = proto.REMEMBER_SELECTION_LIST[0];
      this._select.append(new Option(selection.text, selection.id)).trigger('change');

      //this.renderRememberSelectionList().insertAfter($('.select2-container--open .select2-dropdown .select2-results'));
    }
  };

  proto.attachHandlers = function() {
    this._select = this.buildSelect();

    $(this._select).on('select2:select', $.proxy(this.onSelect, this));
    //$(this._select).on('select2:opening', $.proxy(this.onOpen, this));

    $(this._nodeTaxIdInput).on('blur', $.proxy(this.findTaxId, this));
  };

  proto.findTaxId = function() {
    $.ajax({
      url: 'https://www.ebi.ac.uk/ena/data/taxonomy/v1/taxon/tax-id/'+this._nodeTaxIdInput.val(),
      method: 'GET',
      success: $.proxy(function(data) {
        //debugger;
        var option = new Option(data.scientificName, data.scientificName);
        this._select.append(option).trigger('change');
        this._select.selectRememberedOption(data);
      }, this)
    });
  };

  $(document).ready(function() {
    $(document).trigger('registerComponent.builder', {'TaxonomyControl': TaxonomyControl});
  });

})(jQuery);