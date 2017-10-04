$(document).on('turbolinks:load', function() {

  var table = $('table[data-behavior~=datatable]')
    .DataTable({
      paging: false,
      searching: false,
      ordering: false,
      fixedHeader: {
        header: true,
        footer: false
      }
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
      // fillInTableFromFile($(this), e.originalEvent.dataTransfer.files);
      checkCSVFields($(this), e.originalEvent.dataTransfer.files);
    });

  $('select#material_submission_contact_id').select2({
    tags: true,
    minimumResultsForSearch: Infinity,
    tokenSeparators: [',', ' ']
  });

  $('input:file.upload-button').on('change', function() {
    var sample_table = $(this).closest('.well').siblings().find('table.dataTable');

    fillInTableFromFile(sample_table, $(this)[0].files)

    // Clearing the input allows the change event to fire again
    $(this).val(null);
  });

  // Mirrors dropdown selection between both dropdown menus on the Completed
  // Submissions page
  $('.printer_select').change(function (event) {
    // Get the selection from the dropdown that was changed then update the
    // other dropdown to the same value
    if (event.target.id == "printer_name_top") {
      var selected_printer = $('#printer_name_top').val();
      $('#printer_name_bottom').val(selected_printer);
    } else if (event.target.id == "printer_name_bottom") {
      var selected_printer = $('#printer_name_bottom').val();
      $('#printer_name_top').val(selected_printer);
    }
  });

});

function displayError(msg) {
  $('.alert').html(msg);
  $('.alert').toggleClass('invisible', false);
  $('.alert').toggleClass('hidden', false);
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
