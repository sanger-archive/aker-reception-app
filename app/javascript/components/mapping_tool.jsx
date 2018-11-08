import React, {Fragment} from "react"
import PropTypes from "prop-types"
import { connect } from 'react-redux'

import {matchSelection, unmatch} from '../actions'

let matchedFields = {}

const MODAL_ID = 'myModal'
const FORM_FIELD_SELECT_ID = 'form-fields'
const CSV_SELECT_ID = 'fields-from-csv'
const MAPPING_TABLE_ID = 'matched-fields-table'
const DATA_TABLES = 'div.tab-pane table.dataTable';

// Match the fields selected in the required and CSV selects
function matchFields(schema) {
  var selectedformField = $('#' + FORM_FIELD_SELECT_ID + ' :selected').val()
  var selectedFieldFromCSV = $('#' + CSV_SELECT_ID + ' :selected').val()

  // Check that both fields have been selected
  if (selectedformField && selectedFieldFromCSV) {
    // Add the new match
    matchedFields[selectedformField] = selectedFieldFromCSV

    // Add match to table and remove fields from the selects
    addRowToMatchedTable(schema, selectedformField, selectedFieldFromCSV)
    removeFieldsFromSelects(selectedformField, selectedFieldFromCSV)
  } else {
    alert("Please select a required field and a field from the CSV.")
  }
}

// Unmatch fields and add them back to the selects
function unmatchFields(schema, row) {
  // Extract the data from the row
  var formField = row.children()[1].innerHTML;
  var fieldFromCSV = row.children()[2].innerHTML;

  // Add fields back to the selects
  addFieldToSelect(FORM_FIELD_SELECT_ID, formField, schema.properties[formField].friendly_name + ' (' + formField + ')', schema.properties[formField].required);
  addFieldToSelect(CSV_SELECT_ID, fieldFromCSV, fieldFromCSV, false);

  // Remove the property
  delete matchedFields[formField];
}


// Adds the required and CSV field to the matched table
function addRowToMatchedTable(schema, formField, csvField) {
  $('#' + MAPPING_TABLE_ID + ' > tbody:last-child')
    .append($('<tr>')
      .append(
        $('<td>').text(schema.properties[formField].friendly_name),
        $('<td>').text(formField),
        $('<td>').text(csvField),
        $('<td>').append(
          $('<button>').attr({
            type: 'button',
            class: 'btn btn-danger',
          }).text('x')
            .click(function() {
              var row = $(this).parent().parent();
              unmatchFields(schema, row);

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

const MappingFooter = (props) => {
 return(
  <div className="modal-footer">
    <button type="button" className="btn btn-default" data-dismiss="modal">Cancel</button>
    <button id="complete-csv-matching" type="button" className="btn btn-primary"
      onClick={ () => {
        CSVFieldChecker.fillInTableFromFile(props.content, buildMatchedFields(props.matched), $(DATA_TABLES), props.schema.properties)
        $("#myModal").modal('hide')
      }} >Continue</button>
  </div>
  )
}


const mappingOption = (text, value, pos, required) => {
  return(<option key={pos} value={value}>{required ? '*':''}{text}</option>)
}

const ExpectedMappingOptions = (props) => {
  return(props.expected.map((key, pos) => {
    return mappingOption(props.schema.properties[key].friendly_name, key, pos, props.schema.properties[key].required)
  }))
}

const ObservedMappingOptions = (props) => {
  return(props.observed.map((key, pos) => {
    return mappingOption(key, key, pos, false)
  }))
}

const MappingInterface = (props) => {
  return (
    <div className="row">
      <div className="col-md-5">
        <div className="form-group">
          <label htmlFor="form-fields">Fields on Form</label>
          <select id="form-fields" className="form-control" name="form-fields" size="8">
            <ExpectedMappingOptions expected={props.expected} schema={props.schema} />
          </select>
        </div>
      </div>
      <div className="col-md-5">
        <div className="form-group">
          <label htmlFor="fields-from-csv">Fields from CSV</label>
          <select id="fields-from-csv" className="form-control" name="fields-from-csv" size="8">
            <ObservedMappingOptions observed={props.observed} />
          </select>
        </div>
      </div>
      <div className="col-md-2">
        <div className="form-group">
          <button id="match-fields-button" type="button" className="btn btn-primary"
          onClick={ props.onMatchFields }>Match</button>
        </div>
      </div>
    </div>

    )
}

const MappedPair = (pairInfo, schema, onUnmatch, number) => {
  return(
    <tr key={number.toString()}>
      <td>{ schema.properties[pairInfo.expected].friendly_name }</td>
      <td>{ pairInfo.expected }</td>
      <td>{ pairInfo.observed }</td>
      <td><button className='btn btn-danger' onClick={onUnmatch}>x</button></td>
    </tr>)
}

const MappedPairs = (props) => {
  return(props.matched.map((pair, pos) => { return MappedPair(pair, props.schema, props.onUnmatch, pos) }))
}

const MappedFieldsList = (props) => {
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
          <MappedPairs {...props} />
        </tbody>
      </table>
    </Fragment>
  )
}

const MappingBody = (props) => {
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

      <MappingInterface {...props }/>
      <MappedFieldsList {...props } />
    </div>
    )
}

class MappingToolComponent extends React.Component {
  constructor(props) {
    super(props)
    this.state = {
    }
  }
  componentDidUpdate(){
    if (this.props.expected.length > 0) {
      $("#myModal").modal('show')
    }
      //$(this.modal).on('hidden.bs.modal', this.props.handleHideModal);
  }
  render (props) {
    return(
      <div id="myModal" ref={modal=> this.modal = modal} className="modal fade" tabIndex="-1" role="dialog" data-show="true">
        <div className="modal-dialog modal-lg" role="document">
          <div className="modal-content">
            <MappingHeader />
            <MappingBody {...this.props} />
            <MappingFooter {...this.props} />
          </div>
        </div>
      </div>
    )
  }
}

const mapStateToProps = (state) => {
  return {
    content: state && state.content ? state.content : {},
    expected: state && state.mapping ? state.mapping.expected : [],
    observed: state && state.mapping ? state.mapping.observed : [],
    matched: state && state.mapping ? state.mapping.matched : [],
    schema: state ? state.schema : null
  }
};

const buildMatchedFields = (matched) => {
  return matched.reduce((memo, obj) => {
    memo[obj.expected] = obj.observed
    return memo
  }, {})
}

const mapDispatchToProps = (dispatch, { match, location }) => {
  return {
    onMatchFields: () => {
      let expected = $('#' + FORM_FIELD_SELECT_ID + ' :selected').val()
      let observed = $('#' + CSV_SELECT_ID + ' :selected').val()

      dispatch(matchSelection(expected, observed))
    },
    onUnmatch: (e) => {
      let row = $(e.target).parent().parent()
      let expected = row.children()[1].innerHTML;
      let observed = row.children()[2].innerHTML;

      dispatch(unmatch(expected, observed))
    }
  }
}


let MappingTool = connect(mapStateToProps, mapDispatchToProps)(MappingToolComponent)
export default MappingTool
