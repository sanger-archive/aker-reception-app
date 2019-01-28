import React, { Fragment } from 'react'
import store from '../store'
import { Provider, connect } from 'react-redux'
import MappingTool from './mapping_tool'
import ManifestContainers from './manifest_containers'
import { uploadManifest, loadManifest, saveAndLeave } from '../actions'
import StateSelectors from '../selectors'

import Reception from '../../routes.js.erb'

const logName = (name) => { }
const MessageDisplay = (props) => {
  logName('MessageDisplay')
  return (
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

const showMessages = (props, messages, Renderer) => {
  return messages.map((msg, pos) => {
    if (msg.labware_index && (props.selectedTabPosition != msg.labware_index)) {
      return
    }
    return <Renderer {...msg}
      supplierPlateNames={props.supplierPlateNames}
      selectedTabPosition={props.selectedTabPosition}
      key={pos} />
  })
}


const MessagesDisplayComponent = (props) => {
  logName('MessagesDisplayComponent')
  return (
    <div>
      {showMessages(props, props.warnings, WarningDisplay)}
      {showMessages(props, props.errors, ErrorDisplay)}
    </div>
  )
}

export const MessagesDisplay = connect((state, ownProps) => {
  const selectedTabPosition = StateSelectors.manifest.selectedTabPosition(state)
  return {
    warnings: StateSelectors.content.warningTabMessages(state, selectedTabPosition),
    errors: StateSelectors.content.errorTabMessages(state, selectedTabPosition),
    supplierPlateNames: StateSelectors.manifest.supplierPlateNames(state),
    selectedTabPosition
  }
})(MessagesDisplayComponent)

class ManifestUploaderComponent extends React.Component {
  constructor (props) {
    super(props)
    this.fileInput = React.createRef()
  }
  render () {
    return (
      <input
        ref={this.fileInput}
        onChange={() => { this.props.onChange(this.props.manifestId, this.fileInput.current.files[0]) }}
        id="manifest_upload" type="file" className="upload-button" accept=".csv,.xlsm,.xlsx"
        style={{ 'display': 'none' }} />
    )
  }
}

const ManifestUploader = connect((state) => {
  return {}
}, (dispatch, ownProps) => {
  return {
    onChange: (manifestId, file) => {
      dispatch(uploadManifest(file, manifestId))
    }
  }
})(ManifestUploaderComponent)

const hmdmcWarning = (showHmdmcWarning) => {
  if (showHmdmcWarning) {
    return (
      <Fragment>
        <br />
        <span style={{ 'color': 'red' }}>&#9888; All HMDMC numbers will be saved, but not
            validated with eHMDMC.</span>
      </Fragment>
    )
  }
  return null
}

const InformationDisplayComponent = (props) => {
  const { manifestId, showHmdmcWarning } = props
  return (
    <div style={{ 'marginTop': '10px' }} className={'well csv-upload-box'}>
      <div className="row">
        <div className="venter col-md-10">
          Please drop a Manifest for the current labware onto this box, or the table.
          Alternatively, you can manually enter material provenance for the current
          labware in the table below. Use the tabs above this message to switch
          labware. If necessary, the table can be scrolled horizontally to view all of the fields.
          { hmdmcWarning(showHmdmcWarning) }
        </div>
        <div className="vcenter col-md-2">
          <label style={{ 'float': 'right' }} className="btn btn-primary">
              Browse for Manifest <ManifestUploader manifestId={manifestId} />
          </label>
        </div>
      </div>
    </div>
  )
}

const InformationDisplay = connect((state) => {
  return {
    manifestId: state.manifest.manifest_id,
    showHmdmcWarning: state.manifest.show_hmdmc_warning
  }
})(InformationDisplayComponent)

const ManifestButtonsComponent = (props) => {
  return (
    <div className="row">
      <div className="col-md-12">
        <div style={{ 'margin': '10px 0' }}>
          <a className="btn btn-primary save pull-right" onClick={
            () => { props.goTo(props.paths.next) }
          }>Next</a>
          <a className="btn btn-primary pull-left"
            data-confirm="Are you sure you wish to go back? You will lose unsaved progress on the curent step"
            style={{ 'marginRight': '10px' }} href={props.paths.previous}>Previous</a>
          <a className="btn btn-danger pull-left" data-confirm="Are you sure you wish to cancel this manifest?"
            rel="nofollow" data-method="delete" href={props.paths.cancel}>Cancel Manifest</a>
        </div>
      </div>
    </div>
  )
}

const ManifestButtons = connect((state) => {
  const manifestId = state.manifest.manifest_id

  let paths
  if (typeof Reception === 'undefined') {
    paths = {
      previous: '', cancel: '', next: ''
    }
  } else {
    paths = {
      previous: Reception.manifest_build_path(manifestId, 'labware'),
      cancel: Reception.manifest_path(manifestId),
      next: Reception.manifest_build_path(manifestId, 'ethics')
    }
  }

  return {
    manifestId,
    paths
  }
}, (dispatch) => {
  return {
    goTo: (url) => {
      dispatch(saveAndLeave(url))
    }
  }
})(ManifestButtonsComponent)

export const ManifestEditorComponent = (props) => {
  logName('ManifestEditorComponent')
  return (
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

  return (
    <Provider store={store}>
      <ManifestEditorComponent />
    </Provider>
  )
}

export default ManifestEditor
