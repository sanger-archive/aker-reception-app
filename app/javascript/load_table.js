import { displayError, checkCSVFields } from 'csv_field_checker';
import Reception from './routes';

(function($,undefined) {

  function LoadTable(node, params) {
    this.node = $(node)
    this.params = params;

    this.attachHandlers();
  }

  var proto = LoadTable.prototype;

  proto.attachHandlers = function() {
    var table = this.node.DataTable({
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
    .on('drop', function(e) {
      uploadManifest($(this), e.originalEvent.dataTransfer.files[0]);
    });

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
      .on('drop', function(e) {
        var dataTable = $(this).siblings(".material-data-table").find('.dataTable');
        uploadManifest(dataTable, e.originalEvent.dataTransfer.files[0]);
      });

    $('select#manifest_contact_id').select2({
      tags: true,
      minimumResultsForSearch: Infinity,
      tokenSeparators: [',', ' ']
    });

    $('input:file.upload-button').on('change', function() {
      var sample_table = $(this).closest('.well').siblings().find('table.dataTable');

      uploadManifest(sample_table, $(this)[0].files[0]);

      // Clearing the input allows the change event to fire again
      $(this).val(null);
    });

  }

  function uploadManifest(dataTable, manifest) {
    let formData = new FormData();
    formData.append('manifest', manifest);

    return $.ajax({
      url: Reception.manifests_upload_index_path(),
      type: 'POST',
      data: formData,
      cache: false,
      contentType: false,
      processData: false,
    })
    .then(
      (response) => {
        checkCSVFields(dataTable, response.contents);
      },
      (xhr) => {
        displayError(xhr.responseJSON.errors.join("\n"));
      }
    )

  }

  $(document).ready(function() {
    $(document).trigger('registerComponent.builder', {'LoadTable': LoadTable});
  });

})(jQuery);
