/* eslint no-console:0 */
// This file is automatically compiled by Webpack, along with any other files
// present in this directory. You're encouraged to place your actual application logic in
// a relevant structure within app/javascript and only use these pack files to reference
// that code so it'll be compiled.
//
// To reference this file, add <%= javascript_pack_tag 'application' %> to the appropriate
// layout file, like app/views/layouts/application.html.erb

// [PJ] import the package for jquery-ujs to be initialized
import $ from 'jquery'
import {} from 'jquery-ujs'

// we need to include bootstrap's JS for things like the modal: https://getbootstrap.com/docs/3.3/javascript/
require( 'bootstrap/dist/js/bootstrap');

const moment = require('moment')

// [PJ] need to import datatables in this way to get it working
import dt from 'datatables.net';
import 'datatables.net-bs/js/dataTables.bootstrap.js';
import 'src/application.scss';

require('select2')
require('csv_field_checker')
require('component_builder')
require('data_table_initialization')
require('data_table_schema_validation')
require('taxonomy_id_control')
require('materials_table/materials_table')
require('barcode_reader')
require('sync_select_value')
require('load_table')
require('manifest_csv_warnings')
require('loading_icon')
require('show_previous_in_datatable')


$(document).on("turbolinks:load", function() {
  //$('.has-tooltip').tooltip({trigger: 'click'});
  $('.has-popover').popover({
    trigger: 'hover'
  });
});