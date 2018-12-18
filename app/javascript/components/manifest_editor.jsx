import React from "react"
import PropTypes from "prop-types"
import {Fragment} from "react"
import store from 'store'
import { Provider, connect } from 'react-redux'
import MappingTool from './mapping_tool'
import ManifestContainers from './manifest_containers'
import { loadManifest, selectExpectedOption, selectObservedOption, displayMessage, saveAndLeave} from '../actions'
import StateSelectors from '../selectors'

import Reception from '../routes'

const logName = (name) => { }
const MessageDisplay = (props) => {
  logName('MessageDisplay')
  return(
    <span>At ({props.supplierPlateNames[props.labware_index]} - {props.address} {props.field}): {props.text}</span>
  )
}

const ErrorDisplay = (props) => {
  logName('ErrorDisplay')
  return (
    <div id="page-error-alert" className="alert alert-danger" role="alert">
      <button type="button" className="close" aria-label="Close"><span aria-hidden="true">&times;</span></button>
      <p className='alert-msg'>&nbsp;<MessageDisplay {...props} /></p>
    </div>
    )
}

const WarningDisplay = (props) => {
  logName('WarningDisplay')
  return (
    <div id="page-warning-alert" className="alert alert-warning" role="alert">
      <strong className='alert-title'>Warning!</strong>
      <p className='alert-msg'>&nbsp;<MessageDisplay {...props} /></p>
    </div>
  )
}

const MessagesDisplayComponent = (props) => {
  logName('MessagesDisplayComponent')
  return (
    <div>
      { props.warnings.map((msg, pos) => {
        if (msg.labware_index && (props.selectedTabPosition!=msg.labware_index)) {
          return
        }
        return <WarningsDisplay {...msg}
          supplierPlateNames={props.supplierPlateNames}
          selectedTabPosition={props.selectedTabPosition}
          key={pos} />
      }) }
      { props.errors.map((msg, pos) => {
        if (msg.labware_index && (props.selectedTabPosition!=msg.labware_index)) {
          return
        }
        return <ErrorDisplay {...msg}
          supplierPlateNames={props.supplierPlateNames}
          selectedTabPosition={props.selectedTabPosition}
          key={pos} /> }) }
    </div>
  )
}

const MessagesDisplay = connect((state, ownProps) => {
  const selectedTabPosition = StateSelectors.manifest.selectedTabPosition(state)
  return {
    warnings: StateSelectors.content.warningTabMessages(state, selectedTabPosition),
    errors: StateSelectors.content.errorTabMessages(state, selectedTabPosition),
    supplierPlateNames: StateSelectors.manifest.supplierPlateNames(state),
    selectedTabPosition
  }
})(MessagesDisplayComponent)


const InformationDisplayComponent = (props) => {
  const {manifestId, showHmdmcWarning} = props
  let hmdmcWarning = null
  if (showHmdmcWarning) {
    hmdmcWarning = (
      <Fragment>
        <br />
        <span style={{"color":"red"}}>&#9888; All HMDMC numbers will be saved, but not
            validated with eHMDMC.</span>
      </Fragment>
    )
  }

  return (
    <div style={{"marginTop": "10px"}} className={"well csv-upload-box"}>
      <div className="row">
        <div className="venter col-md-10">
          Please drop a Manifest for the current labware onto this box, or the table.
          Alternatively, you can manually enter material provenance for the current
          labware in the table below. Use the tabs above this message to switch
          labware. If necessary, the table can be scrolled horizontally to view all of the fields.
          { hmdmcWarning }
        </div>
        <div className="vcenter col-md-2">
          <label style={{"float": "right"}} className="btn btn-primary">
              Browse for Manifest <input data-psd-component-class="ManifestUploader"
              data-psd-component-parameters={{"manifest_id": manifestId}}
              id="manifest_upload" type="file" className="upload-button" accept=".csv,.xlsm,.xlsx"
              style={{"display": "none"}} />
          </label>
        </div>
      </div>
    </div>
  )
}


const InformationDisplay = connect((state)=>{
  return {
    manifestId: state.manifest.manifest_id,
    showHmdmcWarning: state.manifest.show_hmdmc_warning
  }
})(InformationDisplayComponent)

const ManifestButtonsComponent = (props) => {
  const {manifestId} = props
  return (
    <div className="row">
      <div className="col-md-12">
        <div style={{"margin": "10px 0"}}>
          <a className="btn btn-primary save pull-right" onClick={
            () => { props.goTo(Reception.manifest_build_path(manifestId, 'ethics')) }
          }>Next</a>
          <a className="btn btn-primary pull-left"
          data-confirm="Are you sure you wish to go back? You will lose unsaved progress on the curent step"
          style={{"marginRight": "10px"}} href={Reception.manifest_build_path(manifestId, 'labware')}>Previous</a>
          <a className="btn btn-danger pull-left" data-confirm="Are you sure you wish to cancel this manifest?"
          rel="nofollow" data-method="delete" href={Reception.manifest_path(manifestId)}>Cancel Manifest</a>
        </div>
      </div>
    </div>
  )
}

const ManifestButtons = connect((state) => {
  return {
    manifestId: state.manifest.manifest_id
  }
}, (dispatch)=> {
  return {
    goTo: (url) => {
      dispatch(saveAndLeave(url))
    }
  }
})(ManifestButtonsComponent)

export const ManifestEditorComponent = (props) => {
  logName('ManifestEditorComponent')
  return(
    <div>
      <ManifestButtons />
      <InformationDisplay />
      <MappingTool />
      <MessagesDisplay />
      <ManifestContainers />
      <ManifestButtons />
    </div>
  )
}

const ManifestEditor = (props) => {
  logName('ManifestEditor')
  if (props && props.manifest) {
    store.dispatch(loadManifest(props))
  }

  $(document.body).on('uploadManifest', (event, request) => {
    return $.ajax(request)
    .then(
      $.proxy(function(response, event) {
        const manifest = response.contents

        store.dispatch(loadManifest(manifest))
        //store.dispatch(loadManifestMapping(manifest.mapping))
        logName(store.getState())
        if (!store.getState().mapping.valid) {
          store.dispatch(selectExpectedOption(null))
          store.dispatch(selectObservedOption(null))

          $('#myModal').modal('show')
        } else {
          //store.dispatch(loadManifestContent(manifest.content))
        }
      }, this),
      (xhr) => {
        store.dispatch(displayMessage({labwareIndex: null, address: null, level: 'FATAL', display: 'alert', text: xhr.responseJSON.errors.join("\n") }))
      }
    )
    .always(() => {
      $(document).trigger('hideLoadingOverlay');
    })
  })
  //$(document.body).on('uploadedmanifest', )

  return(
    <Provider store={store}>
      <ManifestEditorComponent />
    </Provider>
  )
}

export default ManifestEditor
