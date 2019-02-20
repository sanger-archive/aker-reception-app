import $ from 'jquery'

(function () {
  function DataTableInitialization (node, params) {
    this.node = $(node)
    this.initDataTable(params)

    this.attachHandlers()
  };

  var proto = DataTableInitialization.prototype

  proto.initDataTable = function (params) {
    this.dataTable = $(this.node).DataTable(params)
  }

  proto.attachHandlers = function () {
    this.node.on('DataTableInitialization.addRow', $.proxy(this.onAddRow, this))
  }

  proto.onAddRow = function (e, data) {
    this.dataTable.row.add(data)
    this.dataTable.draw()
  }

  $(document).ready(function () {
    $(document).trigger('registerComponent.builder', { 'DataTableInitialization': DataTableInitialization })
  })
}())

$.fn.dataTable.ext.type.detect.unshift(
    function ( d ) {
      return ((!!$(d).data('sort-with')) ? 'reception-date' : null)
    }
)

$.fn.dataTable.ext.type.order['reception-date-pre'] = function ( d ) {
  return $(d).data('sort-with')
}
