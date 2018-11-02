import React, {Fragment} from "react"
import PropTypes from "prop-types"

let matchedFields = {}

const MODAL_ID = 'myModal'
const FORM_FIELD_SELECT_ID = 'form-fields'
const CSV_SELECT_ID = 'fields-from-csv'
const MAPPING_TABLE_ID = 'matched-fields-table'

// Match the fields selected in the required and CSV selects
function matchFields() {
  var selectedformField = $('#' + FORM_FIELD_SELECT_ID + ' :selected').val()
  var selectedFieldFromCSV = $('#' + CSV_SELECT_ID + ' :selected').val()

  // Check that both fields have been selected
  if (selectedformField && selectedFieldFromCSV) {
    // Add the new match
    matchedFields[selectedformField] = selectedFieldFromCSV

    // Add match to table and remove fields from the selects
    addRowToMatchedTable(selectedformField, selectedFieldFromCSV)
    removeFieldsFromSelects(selectedformField, selectedFieldFromCSV)
  } else {
    alert("Please select a required field and a field from the CSV.")
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

// Remove the matched fields from the selects to prevent users from selecting them again
function removeFieldsFromSelects(formField, csvField) {
  $("#" + FORM_FIELD_SELECT_ID + " option[value='" + formField + "']").remove();
  $("#" + CSV_SELECT_ID + " option[value='" + csvField + "']").remove();
}


const MappingHeader = () => {
  return (
    <div className="modal-header">
      <button type="button" className="close"
        data-dismiss="modal" aria-label="Close">
          <span aria-hidden="true">&times;</span>
      </button>
      <h4 className="modal-title">Select CSV mappings</h4>
    </div>
    )
}

const MappingFooter = () => {
 return(
  <div className="modal-footer">
    <button type="button" className="btn btn-default" data-dismiss="modal">Cancel</button>
    <button id="complete-csv-matching" type="button" className="btn btn-primary"
      onClick={ () => { alert("CSVFieldChecker.finishCSVCheck()") }} >Continue</button>
  </div>
  )
}

const MappingInterface = () => {
  return (
    <div className="row">
      <div className="col-md-5">
        <div className="form-group">
          <label htmlFor="form-fields">Fields on Form</label>
          <select id="form-fields" className="form-control" name="form-fields" size="8">
          </select>
        </div>
      </div>
      <div className="col-md-5">
        <div className="form-group">
          <label htmlFor="fields-from-csv">Fields from CSV</label>
          <select id="fields-from-csv" className="form-control" name="fields-from-csv" size="8">
          </select>
        </div>
      </div>
      <div className="col-md-2">
        <div className="form-group">
          <button id="match-fields-button" type="button" className="btn btn-primary"
          onClick={ matchFields }>Match</button>
        </div>
      </div>
    </div>

    )
}

const MappedFields = () => {
  return (
    <Fragment>
      <h5>Matched fields</h5>
      <table id="matched-fields-table" className="table">
        <thead>
          <tr>
            <th></th>
            <th>Available field</th>
            <th>Field from CSV</th>
            <th></th>
          </tr>
        </thead>
        <tbody>
        </tbody>
      </table>
    </Fragment>
  )
}

const MappingBody = () => {
  return (
    <div className="modal-body">
      <div id="modal-alert-required" className="alert alert-error" role="alert" style={{ display: 'none' }}>
        All the required fields must be mapped to a CSV field.
      </div>
      <div id="modal-alert-ignored" className="alert alert-warning" role="alert" style={{ display: 'none'}}>
        Some fields from the CSV have been ignored, please confirm that the correct matches have been made.
      </div>
      <p>
        Please select a form field on the left and the CSV field on the right, then press the "Match"
        button to map them. Fields marked with a * must be mapped.
      </p>

      <MappingInterface />
      <MappedFields />
    </div>
    )
}

class MappingTool extends React.Component {
  render () {
    return(
      <div id="myModal" className="modal fade" tabIndex="-1" role="dialog">
        <div className="modal-dialog modal-lg" role="document">
          <div className="modal-content">
            <MappingHeader />
            <MappingBody />
            <MappingFooter />
          </div>
        </div>
      </div>
    )
  }
}


export default MappingTool
