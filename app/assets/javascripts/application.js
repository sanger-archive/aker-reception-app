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
//= require bootstrap-table
//= require csv_field_checker
//= require load_table
//= require taxonomy_control
//= require_tree ./templates
//= require_tree .

$(document).on("turbolinks:load", function() {
  $('.has-tooltip').tooltip();
  $('.has-popover').popover({
    trigger: 'hover'
  });
});

$(document).on("turbolinks:load", function() {
  $('td[data-psd-schema-validation-name=scientific_name] input').each(function(pos, input) {
    //var selectNode = $('<select style="width: 100%;"></select>');
    //var selectNode = $('<input disabled="disabled"></input>')
    //$(input).replaceWith(selectNode)
    //new TaxonomyControl(selectNode, []);
  });
});