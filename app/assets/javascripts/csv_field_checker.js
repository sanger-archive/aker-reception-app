const MODAL_ID = 'myModal';
const FORM_FIELD_SELECT_ID = 'form-fields';
const CSV_SELECT_ID = 'fields-from-csv';
const MAPPING_TABLE_ID = 'matched-fields-table';
const MODAL_ALERT_REQUIRED_ID = 'modal-alert-required';
const MODAL_ALERT_IGNORED_ID = 'modal-alert-ignored';

// Position field that needs to be added to the schema which comes from the material service
const POSITION_FIELD = {
  required: true,
  field_name_regex: "^(well(\\s*|_*|-*))?position$",
  friendly_name: "Position",
  show_on_form: true
}

// Set a few global variables -- bad idea, should move this all into a class!
var matchedFields = {};
var schema = {};
var fieldsOnForm = [];
var fieldsFromCSV = [];
var requiredFields = [];
var file = null;
var dataTable = null;

// Checks the header fields from the CSV against the fields required for the material service
// TODO: refactor into class
function checkCSVFields(table, files) {
  // If we have not received any files, return
  if (files.length != 1) {
    return false
  }

  // Get the table and file
  dataTable = table;
  file = files[0];

  // Clear the matched fields
  matchedFields = {};

  // Get the schema from the rails view
  schema = materialSchema.properties;
  fieldsOnForm = materialSchema.show_on_form;
  requiredFields = materialSchema.required;

  // Check that we have received a schema
  if (Object.keys(schema).length < 1) {
    return false
  }

  // Hide any alerts
  $('#' + MODAL_ALERT_REQUIRED_ID).hide();
  $('#' + MODAL_ALERT_IGNORED_ID).hide();

  // Add position field to schema and required list
  if (!schema.position) {
    schema.position = POSITION_FIELD;
    materialSchema.show_on_form.push('position');
  }

  // Show the schema if we need to debug
  debug("schema:");
  debug(schema);

  // Get the header fields using PapaParse
  Papa.parse(file, {
    header: true,
    preview: 1, // Just get one line to do a quick check of the file
    skipEmptyLines: true,
    // The complete callback executes when the parsing is complete
    complete: function(results) {
      // If there are errors, display them and return
      if (results.errors.length > 0) {
        displayError(csvErrorToText(results.errors));
        return false;
      }

      // If Papa was able to parse the CSV file, extract the header fields and show for debugging
      fieldsFromCSV = results.meta.fields;
      debug("fieldsFromCSV:");
      debug(fieldsFromCSV);

      // Do the magic!
      if (fieldsFromCSV.length > 0) {
        // Create "fields from CSV" select
        // Empty the current select first
        $('#' + CSV_SELECT_ID).empty();
        // Add an option for each field
        $.each(fieldsFromCSV, function (ffcKey, ffcValue) {
          addFieldToSelect(CSV_SELECT_ID, ffcValue, ffcValue, false);

          // Match form fields and CSV fields
          // Iterate through the CSV fields, checking if it matches the regex in the visible fields
          $.each(schema, function (rfKey, rfValue) {
            // We are only interested in the visible (show_on_form = true) fields at this point and they need a regex to match against
            if (rfValue.hasOwnProperty('show_on_form') && rfValue.show_on_form && rfValue.hasOwnProperty('field_name_regex')) {
              // Match using case-insensitivity
              var pattern = new RegExp(rfValue.field_name_regex, 'i');

              // Check the regex pattern for the required field against the CSV field
              if (pattern.test($.trim(ffcValue))) {
                matchedFields[rfKey] = ffcValue;
                return false;
              }
            }
          });
        });

        debug("automatically matched fields:");
        debug(matchedFields);

        // Create "required fields" select
        $('#' + FORM_FIELD_SELECT_ID).empty();
        $.each(schema, function (key, value) {
          if (value.hasOwnProperty('show_on_form') && value.show_on_form && value.friendly_name) {
            addFieldToSelect(FORM_FIELD_SELECT_ID, key, value.friendly_name + ' (' + key + ')', value.required);
          }
        });

        // Clear and populate matched table
        $("#" + MAPPING_TABLE_ID + " > tbody").html("");
        if (matchedFields) {
          $.each(matchedFields, function (propName, propValue) {
            addRowToMatchedTable(propName, propValue);
            removeFieldsFromSelects(propName, propValue);
          });
        }

        // Only show the modal dialog if there are un-matched fields or we have ignored fields from the CSV
        var fieldsIgnored = csvFieldsIgnored();
        if (fieldsIgnored) $('#' + MODAL_ALERT_IGNORED_ID).show();
        if (!allRequiredMatched() || fieldsIgnored) {
          $('#' + MODAL_ID).modal('toggle');
        } else {
          fillInTableFromFile();
        }
      } else {
        displayError(csvErrorToText(results.errors));
      }
    },
  });
}

// Checks if there are more fields in the CSV that could have been ignored
function csvFieldsIgnored() {
  if ((Object.keys(matchedFields).length == Object.keys(fieldsOnForm).length)
        && (fieldsFromCSV.length > Object.keys(fieldsOnForm).length)) {
    return true;
  }
  return false;
}

// Checks if all required fields have been matched
function allRequiredMatched() {
  return requiredFields.every(function(val) {
    return Object.keys(matchedFields).indexOf(val) >= 0;
  })
}

// Remove the matched fields from the selects to prevent users from selecting them again
function removeFieldsFromSelects(formField, csvField) {
  $("#" + FORM_FIELD_SELECT_ID + " option[value='" + formField + "']").remove();
  $("#" + CSV_SELECT_ID + " option[value='" + csvField + "']").remove();
}

// Adds the required and CSV field to the matched table
function addRowToMatchedTable(formField, csvField) {
  $('#' + MAPPING_TABLE_ID + ' > tbody:last-child')
    .append($('<tr>')
      .append(
        $('<td>').text(schema[formField].friendly_name),
        $('<td>').text(formField),
        $('<td>').text(csvField),
        $('<td>').append(
          $('<button>').attr({
            type: 'button',
            class: 'btn btn-danger',
          }).text('x')
            .click(function() {
              var row = $(this).parent().parent();
              unmatchFields(row);

              // Remove the table row
              row.remove();
            })
        )
      )
    );
}

// Match the fields selected in the required and CSV selects
function matchFields() {
  var selectedformField = $('#' + FORM_FIELD_SELECT_ID + ' :selected').val();
  var selectedFieldFromCSV = $('#' + CSV_SELECT_ID + ' :selected').val();

  // Check that both fields have been selected
  if (selectedformField && selectedFieldFromCSV) {
    // Add the new match
    matchedFields[selectedformField] = selectedFieldFromCSV;

    // Add match to table and remove fields from the selects
    addRowToMatchedTable(selectedformField, selectedFieldFromCSV);
    removeFieldsFromSelects(selectedformField, selectedFieldFromCSV);
  } else {
    alert("Please select a required field and a field from the CSV.");
  }
}

// Unmatch fields and add them back to the selects
function unmatchFields(row) {
  // Extract the data from the row
  var formField = row.children()[1].innerHTML;
  var fieldFromCSV = row.children()[2].innerHTML;

  // Add fields back to the selects
  addFieldToSelect(FORM_FIELD_SELECT_ID, formField, schema[formField].friendly_name + ' (' + formField + ')', schema[formField].required);
  addFieldToSelect(CSV_SELECT_ID, fieldFromCSV, fieldFromCSV, false);

  // Remove the property
  delete matchedFields[formField];
}

// Add options back to the specific select
function addFieldToSelect(select, value, text, required) {
  $('#' + select).append($('<option>', {
    value: value,
    text : required ? '*' + text : text
  }));
}

// Completes the matching
function finishCSVCheck() {
  if (allRequiredMatched()) {
    fillInTableFromFile();

    // Hide the modal after all the data has been imported
    $('#' + MODAL_ID).modal('hide');
  } else {
    // Tell the user that all required fields require a match
    $('#' + MODAL_ALERT_REQUIRED_ID).show();
  }
}

// Complete the data table using the mapped fields and CSV
function fillInTableFromFile() {
  Papa.parse(file, {
    header: true,
    skipEmptyLines: true,
    complete: function(results) {
      debug("results from parse:");
      debug(results);

      // Show any errors to the users
      if (results.errors.length > 0) {
        displayError(csvErrorToText(results.errors));

        // Stop filling in data
        // TODO: should we clear the file if we have one row incorrect?
        return false;
      }

      // Clear the table from previous import
      $('#' + dataTable.attr('id') + ' > tbody > tr').each(function() {
        $this = $(this);
        $this.children().each (function(cell) {
          $cell = $(this);
          $cell.find('input').val('');
        });
      });

      // Write each row to the datatable
      results.data.every(function(row, index) {
        // Get the row for of the well we would like to fill data
        var tableRow = $('tr[data-address="' + row[matchedFields.position] + '"]', dataTable);

        // No position, no data
        if (!row[matchedFields.position] || tableRow.length == 0) {
          displayError('This manifest does not have a valid position field for the wells of row: ' + index);
          return false;
        };

        // Fill in the actual row with the data
        $.each(matchedFields, function (formField, csvField) {
          var value = row[csvField].trim();
          if (schema[formField]["allowed"] === undefined) {
            // Text input fields
            tableRow.find('input[name*="' + formField + '"]').val(value);

            // We also need to set the value attribute for Capybara to see and pass the test
            // .prop is similar to .val so .attr seems to be working
            // https://stackoverflow.com/a/6057122
            // TODO: Find a fix or implement correctly as we are double filling the value here
            tableRow.find('input[name*="' + formField + '"]').attr('value', value);
          } else {
            // Dropdown input fields
            var selectValue = find_ci(schema[formField]["allowed"], value);
            if (value && !selectValue) {
              displayError("The value '"+value+"' could not be entered for field '"+formField+"'.");
              return false;
            }
            tableRow.find('select[name*="' + formField + '"]').val(selectValue);
            // TODO regex checks?
          }
        });

        return true;
      });
      debug("importing complete!");
    },
  })
}

function find_ci(array, value) {
  var len = array.length;
  value = value.toLowerCase();
  for (var i = 0; i < len; ++i) {
    if (array[i].toLowerCase()===value) {
      return array[i];
    }
  }
  return null;
}

// Helper function to send some debugging messages if we trigger it from a parameter
function debug(toLog) {
  if (getURLParameter('debug') === 'true') console.log(toLog);
}

// Fancy function to get parameters from the URL
// https://stackoverflow.com/a/11582513
function getURLParameter(name) {
  return decodeURIComponent((new RegExp('[?|&]' + name + '=' + '([^&;]+?)(&|#|;|$)').exec(location.search) || [null, ''])[1].replace(/\+/g, '%20')) || null;
}
