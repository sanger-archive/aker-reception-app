(function($,undefined) {
  function LoadTable(node, params) {
    this.node = $(node)
    this.params = params;

    this.attachHandlers();
  }

  function displayError(msg) {
    const PAGE_ERROR_ALERT_ID = "#page-error-alert";
    $(PAGE_ERROR_ALERT_ID).html(msg);
    $(PAGE_ERROR_ALERT_ID).toggleClass('invisible', false);
    $(PAGE_ERROR_ALERT_ID).toggleClass('hidden', false);
  }

  function csvErrorToText(list) {
    var nodes = [];
    for (var i=0; i<list.length; i++) {
      var li = document.createElement('li')
      $(li).html(["<b>", list[i].code, "</b>:", list[i].row ? "At row " + list[i].row : '', list[i].message].join(' '));
      nodes.push(li);
    }
    return nodes;
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
      checkCSVFields($(this), e.originalEvent.dataTransfer.files);
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
        checkCSVFields(dataTable, e.originalEvent.dataTransfer.files);
      });

    $('select#material_submission_contact_id').select2({
      tags: true,
      minimumResultsForSearch: Infinity,
      tokenSeparators: [',', ' ']
    });

    $('input:file.upload-button').on('change', function() {
      var sample_table = $(this).closest('.well').siblings().find('table.dataTable');

      checkCSVFields(sample_table, $(this)[0].files);

      // Clearing the input allows the change event to fire again
      $(this).val(null);
    });

  }
  

  $(document).ready(function() {
    $(document).trigger('registerComponent.builder', {'LoadTable': LoadTable});
  });

})(jQuery);
