(function($, undefined) {
  /**
  * This component works with 3 elements:
  * 1. An input to read a barcode with the following behaviour:
  *     - On tabulator or carriage return will send the form (2)
  * 2. A form that will obtain a data object about the barcode provided in the input:
  *     - On success, it will trigger an event DataTableInitialization.addRow with some data inside an array
  * 3. A table using DataTable js and DataTableInitialization class to manage the answer
  **/
  function BarcodeReader(node, params) {
    this.node = $(node);

    this.form = $('form', this.node);
    this.table = $('table tbody', this.node);
    this.containerTable = $('table', this.node);
    this.inputReader = $('input', this.node);

    this.initTable(params);
    this.attachHandlers();

    this.inputReader.focus();
  };

  var proto = BarcodeReader.prototype;

  proto.readInput = function(e) {
    if ((e.keyCode === 9) || (e.keyCode == 13)) {
      e.preventDefault();
      $(this.form).submit();
      $(this.inputReader).val('');
    }
  };

  proto.addRow = function(rowInfo) {
    this.rows.push(rowInfo);
    this.containerTable.trigger('DataTableInitialization.addRow', [[rowInfo.labware.barcode, rowInfo.created_at]]);
  };

  proto.initTable = function(rows) {
    this.rows = [];
    for (var i=0; i<this.rows.length; i++) {
      this.addRow(this.rows[i]);
    }
  };

  proto.alert = function(msg) {
    $('.alert .alert-msg').html(msg);
    $('.alert').toggleClass('invisible', false);
  };

  proto.onReceivedBarcode = function(e, json) {
    if (typeof json.error !== 'undefined') {
      this.alert(json.error);
    } else {
      $('.alert').toggleClass('invisible', true);
      this.addRow(json);
    }
  };

  proto.displayeError = function(e, json) {
    this.alert(json);
  };

  proto.attachHandlers = function() {
    $(this.inputReader).on('keydown', $.proxy(this.readInput, this));
    $(this.form).on('ajax:success', $.proxy(this.onReceivedBarcode, this));
    $(this.form).on('ajax:error', $.proxy(this.displayError, this));
  };

  $(document).ready(function() {
    $(document).trigger('registerComponent.builder', {'BarcodeReader': BarcodeReader});
  });

}(jQuery));
