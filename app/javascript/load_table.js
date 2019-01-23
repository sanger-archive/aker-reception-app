import { uploadManifest } from 'react/actions'
import store from 'react/store'

(function ($, undefined) {
  function LoadTable (node, params) {
    this.node = $(node)
    this.params = params

    this.attachHandlers()
  }

  var proto = LoadTable.prototype

  proto.attachHandlers = function () {
    this.dataTable = this.node.DataTable({
      paging: false,
      searching: false,
      ordering: false
    })
      .on('drag dragstart dragend dragover dragenter dragleave drop', function (e) {
        e.preventDefault()
        e.stopPropagation()
      })
      .on('dragover dragenter', function () {
        $(this).addClass('is-dragover bg-info').removeClass('table-striped')
      })
      .on('dragleave dragend drop', function () {
        $(this).removeClass('is-dragover bg-info').addClass('table-striped')
      })
      .on('drop', $.proxy(function (e) {
        store.dispatch(uploadManifest(e.originalEvent.dataTransfer.files[0], this.params.manifest_id))
      }, this))

    var csvBox = $('.csv-upload-box')
      .on('drag dragstart dragend dragover dragenter dragleave drop', function (e) {
        e.preventDefault()
        e.stopPropagation()
      })
      .on('dragover dragenter', function () {
        $(this).addClass('is-dragover bg-info')
      })
      .on('dragleave dragend drop', function () {
        $(this).removeClass('is-dragover bg-info')
      })
      .on('drop', $.proxy(function (e) {
        store.dispatch(uploadManifest(e.originalEvent.dataTransfer.files[0], this.params.manifest_id))
      }, this))
  }

  $(document).ready(function () {
    $(document).trigger('registerComponent.builder', { 'LoadTable': LoadTable })
  })
})(jQuery)
