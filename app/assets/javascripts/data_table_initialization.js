(function() {

  function DataTableInitialization(node, params) {
    this.node = $(node);
    this.dataTable = $(node).DataTable(params);

    this.attachHandlers();
  };

  var proto = DataTableInitialization.prototype;

  proto.attachHandlers = function() {
    this.node.on('DataTableInitialization.addRow', $.proxy(this.onAddRow, this));
  };

  proto.onAddRow = function(e, data) {
    this.dataTable.row.add(data);
    this.dataTable.draw();
  };

  $(document).ready(function() {
    $(document).trigger('registerComponent.builder', {'DataTableInitialization': DataTableInitialization});
  });

}(jQuery));
