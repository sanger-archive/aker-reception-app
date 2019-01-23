import $ from 'jquery'
import moment from 'moment'

(function () {
  /**
  * This component works with 3 elements:
  * 1. An input to read a barcode with the following behaviour:
  *     - On tabulator or carriage return will send the form (2)
  * 2. A form that will obtain a data object about the barcode provided in the input:
  *     - On success, it will trigger an event DataTableInitialization.addRow with some data inside an array
  * 3. A table using DataTable js and DataTableInitialization class to manage the answer
  **/
  function BarcodeReader (node, params) {
    this.node = $(node)

    this.form = $('form', this.node)
    this.table = $('table tbody', this.node)
    this.containerTable = $('table', this.node)
    this.inputReader = $('input', this.node)

    this.initTable(params)
    this.attachHandlers()

    this.inputReader.focus()
  };

  var proto = BarcodeReader.prototype

  proto.readInput = function (e) {
    if ((e.keyCode === 9) || (e.keyCode === 13)) {
      e.preventDefault()
      this.inputReader[1].value = this.inputReader[1].value.trim()
      $(this.form).submit()
      $(this.inputReader).val('')
    }
  }

  proto.addRow = function (rowInfo) {
    // Use moment for time formatting: http://momentjs.com/
    // Set locale
    moment.locale('en-gb')
    // Convert to date with time:  19 Sep 2017 10:09
    rowInfo.created_at = moment(rowInfo.created_at).format('lll')
    this.rows.push(rowInfo)
    this.containerTable.trigger('DataTableInitialization.addRow', [[rowInfo.labware.barcode, rowInfo.created_at]])
  }

  proto.initTable = function (rows) {
    this.rows = []
    for (var i = 0; i < this.rows.length; i++) {
      this.addRow(this.rows[i])
    }
  }

  proto.alert = function (msg) {
    $('.alert .alert-msg').html(msg)
    $('.alert').toggleClass('hidden', false)
  }

  proto.onReceivedBarcode = function (e, json) {
    if (typeof json.error !== 'undefined') {
      $('.alert').toggleClass('alert-success', false)
      $('.alert').toggleClass('alert-danger', true)
      this.alert(json.error)
    } else {
      $('.alert .alert-msg').html('Barcode scanned')
      $('.alert').toggleClass('alert-danger', false)
      $('.alert').toggleClass('alert-success', true)
      $('.alert').toggleClass('hidden', false)
      this.addRow(json)
    }
  }

  proto.displayError = function (e) {
    this.alert('There is a network connection problem with the server. Please, contact the administrator.')
  }

  proto.attachHandlers = function () {
    $(this.inputReader).on('keydown', $.proxy(this.readInput, this))
    $(this.form).on('ajax:success', $.proxy(this.onReceivedBarcode, this))
    $(this.form).on('ajax:error', $.proxy(this.displayError, this))
  }

  $(document).ready(function () {
    $(document).trigger('registerComponent.builder', { 'BarcodeReader': BarcodeReader })
  })
}())
