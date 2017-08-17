// This is a manifest file that'll be compiled into application.js, which will include all the files
// listed below.
//
// Any JavaScript/Coffee file within this directory, lib/assets/javascripts, vendor/assets/javascripts,
// or any plugin's vendor/assets/javascripts directory can be referenced here using a relative path.
//
// It's not advisable to add code directly here, but if you do, it'll appear at the bottom of the
// compiled file. JavaScript code in this file should be added after the last require_* statement.
//
// Read Sprockets README (https://github.com/rails/sprockets#sprockets-directives) for details
// about supported directives.
//
//= require jquery
//= require jquery_ujs
//= require turbolinks
//= require bootstrap-sprockets
//= require select2
//= require component_builder
//= require single_table_manager
//= require barcode_reader
//= require_tree .
//= require bootstrap-table

var field_mapping = {
  position: 'position',
  material: 'supplier_name',
  donor: 'donor_name',
  gender: 'gender',
  common: 'common_name',
  phenotype: 'phenotype'
}

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
      fillInTableFromFile($(this), e.originalEvent.dataTransfer.files);
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

})

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

function fillInTableFromFile(table, files) {
  if (files.length != 1) {
    return false
  }

  Papa.parse(files[0], {
    complete: function(results) {
      console.log(results)

      if (results.errors.length > 0) {

        displayError(csvErrorToText(results.errors));

        return false;
      }

      results.data.forEach(function(row) {
        var wellValue;

        for (var key in row) {
          if (key.toLowerCase().indexOf('position') != -1) {
            wellValue = row[key];
            delete row[key];
            break;
          }
        }

        // No wellValue, no data
        if (!wellValue) {
          displayError('This manifest does not have a position field for the wells')
          return;
        };

        var tableRow = $('tr[data-address="'+wellValue+'"]', table);

        for (var key in row) {
          tableRow.find('input[name*="'+key+'"]').val(row[key]);
        }
      })
    },
    header: true,
    skipEmptyLines: true
  })
}
$(document).on("turbolinks:load", function() {
  $('.has-tooltip').tooltip();
  $('.has-popover').popover({
    trigger: 'hover'
  });
});
