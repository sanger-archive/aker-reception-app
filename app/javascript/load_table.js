//import { uploadManifest } from 'csv_field_checker';

(function($,undefined) {


  function LoadTable(node, params) {
    this.node = $(node)
    this.params = params;

    this.attachHandlers();
  }

  var proto = LoadTable.prototype;

  proto.attachHandlers = function() {
    this.dataTable = this.node.DataTable({
      paging: false,
      searching: false,
      ordering: false
    })
    .on('drag dragstart dragend dragover dragenter dragleave drop', function(e) {
      e.preventDefault();
      e.stopPropagation();
    })
    .on('dragover dragenter', function() {
      $(this).addClass('is-dragover bg-info').removeClass('table-striped')
    })
    .on('dragleave dragend drop', function() {
      $(this).removeClass('is-dragover bg-info').addClass('table-striped')
    })
    .on('drop', $.proxy(function(e) {
      uploadManifest.call(this, e.originalEvent.dataTransfer.files[0], this.params.manifest_id);
    }, this));

    var csvBox = $('.csv-upload-box')
      .on('drag dragstart dragend dragover dragenter dragleave drop', function(e) {
        e.preventDefault();
        e.stopPropagation();
      })
      .on('dragover dragenter', function() {
        $(this).addClass('is-dragover bg-info')
      })
      .on('dragleave dragend drop', function() {
        $(this).removeClass('is-dragover bg-info')
      })
      .on('drop', $.proxy(function(e) {
        uploadManifest.call(this, e.originalEvent.dataTransfer.files[0], this.params.manifest_id);
      }, this));

    $('select#manifest_contact_id').select2({
      tags: true,
      minimumResultsForSearch: Infinity,
      tokenSeparators: [',', ' ']
    });

  }

  $(document).ready(function() {
    $(document).trigger('registerComponent.builder', {'LoadTable': LoadTable});
  });

})(jQuery);
