(function($, undefined) {
  function BarcodeReader(node, params) {
    this.node = $(node);
    this.rows = params;

    this.form = $('form', this.node);
    this.table = $('table tbody', this.node);
    this.inputReader = $('input', this.node);

    this.renderTable();
    this.attachHandlers();
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
    this.table.append(['<tr><td>',rowInfo.labware.barcode,
          '</td><td>', rowInfo.created_at, '</td></tr>'].join(''));
  };

  proto.renderTable = function() {
    this.table.html('');
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
      this.rows.push(json)
      this.renderTable();
    }
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
