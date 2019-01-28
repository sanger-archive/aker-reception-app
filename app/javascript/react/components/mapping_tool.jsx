import React, {Fragment} from "react"
import PropTypes from "prop-types"
import { connect } from 'react-redux'
import { Modal } from 'react-bootstrap';
import {matchSelection, unmatch, selectExpectedOption, selectObservedOption, toggleMapping, saveTab } from '../actions'


const MappingHeaderComponent = (props) => {
  return (
    <Modal.Header>
      <button type="button" className="close" onClick={props.onClickClose}
        data-dismiss="modal" aria-label="Close">
          <span aria-hidden="true">&times;</span>
      </button>
      <Modal.Title>Select CSV mappings</Modal.Title>
    </Modal.Header>
  )
}

const MappingHeader = connect((status) => {return {}}, (dispatch) => {
  return {
    onClickClose: () => {
      dispatch(toggleMapping(false))
    }
  }
})(MappingHeaderComponent)


const MappingFooterComponent = (props) => {
 return(
  <Modal.Footer>
    <button type="button" className="btn btn-default" data-dismiss="modal">Cancel</button>
    <button id="complete-csv-matching" type="button" className="btn btn-primary"
      onClick={ () => { props.onAccept() } }
      disabled={!props.valid}  >Accept</button>
  </Modal.Footer>
  )
}

const MappingFooter = connect((state) => { return{} }, (dispatch) => {
  return {onAccept: () => { dispatch(toggleMapping(false))} }
})(MappingFooterComponent)

const mappingOption = (text, value, pos, required, onClick) => {
  return(<option key={pos} value={value} onClick={() => {onClick(value)}}>{required ? '*':''}{text}</option>)
}

const ExpectedMappingOptions = (props) => {
  return(props.expected.map((key, pos) => {
    return mappingOption(props.schema.properties[key].friendly_name, key, pos, props.schema.properties[key].required, props.onSelectExpectedOption)
  }))
}

const ObservedMappingOptions = (props) => {
  return(props.observed.map((key, pos) => {
    return mappingOption(key, key, pos, false, props.onSelectObservedOption)
  }))
}

const MappingInterface = (props) => {
  return (
    <div className="row">
      <div className="col-md-5">
        <div className="form-group">
          <label htmlFor="form-fields">Fields on Form</label>
          <select id="form-fields" className="form-control" name="form-fields" size="8" defaultValue={props.selectedExpected||""}>
            <ExpectedMappingOptions {...props} />
          </select>
        </div>
      </div>
      <div className="col-md-5">
        <div className="form-group">
          <label htmlFor="fields-from-file">Fields from File</label>
          <select id="fields-from-file" className="form-control" name="fields-from-file" size="8" defaultValue={props.selectedObserved||""}>
            <ObservedMappingOptions {...props} />
          </select>
        </div>
      </div>
      <div className="col-md-2">
        <div className="form-group">
          <button id="match-fields-button" type="button" className="btn btn-primary"
          disabled={(!props.selectedExpected || !props.selectedObserved)}
          onClick={ () => { props.onMatchFields(props.selectedExpected, props.selectedObserved) }}>Match</button>
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
      <td><button className='btn btn-danger' onClick={() => {onUnmatch(pairInfo.expected, pairInfo.observed)}}>x</button></td>
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
    <Modal.Body className="mapping-modal">
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
    </Modal.Body>
    )
}


const MappingToolComponent = (props) => {
  if (props.shown) {
    return(
        <Modal.Dialog backdrop={"true"} >
          <MappingHeader />
          <MappingBody {...props} style={
          {
            height: '700px',
            overflow: 'scroll'
          }
        } />
          <MappingFooter {...props} />
        </Modal.Dialog>
    )
  }
  return null
}

const mapStateToProps = (state) => {

  return {
    selectedObserved: state?.mapping?.selectedObserved || null,
    selectedExpected: state?.mapping?.selectedExpected || null,
    content: state?.content || {},
    expected: state?.mapping?.expected || [],
    observed: state?.mapping?.observed || [],
    matched: state?.mapping?.matched || [],
    shown: (typeof state?.mapping?.shown !=='undefined') ? state.mapping.shown : !!state?.mapping?.hasUnmatched,
    valid: !!state?.mapping?.valid,
    schema: state?.schema || null
  }
};

const buildMatchedFields = (matched) => {
  return matched.reduce((memo, obj) => {
    memo[obj.expected] = obj.observed
    return memo
  }, {})
}

const reduceAndProcess = (obj, process) => {
  return Object.keys(obj).reduce((memo, key) => {
    memo[key] = process(obj, key)
    return memo
  }, {})
}

const buildContentFromStructured = (structured) => {
  return reduceAndProcess(structured.labwares, (memo, labId) => {
    return reduceAndProcess(structured.labwares[labId].addresses, (memo, address) => {
      return reduceAndProcess(structured.labwares[labId].addresses[address].fields, (memo, field) => {
        return structured.labwares[labId].addresses[address].fields[field].value
      })
    })
  })
}


const mapDispatchToProps = (dispatch, { match, location }) => {
  return {
    onSelectExpectedOption: (value) => {
      dispatch(selectExpectedOption(value))
    },
    onSelectObservedOption: (value) => {
      dispatch(selectObservedOption(value))
    },
    onMatchFields: (expected, observed) => {
      dispatch(matchSelection(expected, observed))
      dispatch(saveTab())
    },
    onUnmatch: (expected, observed) => {
      dispatch(unmatch(expected, observed))
      dispatch(saveTab())
    }
  }
}


let MappingTool = connect(mapStateToProps, mapDispatchToProps)(MappingToolComponent)
export default MappingTool
