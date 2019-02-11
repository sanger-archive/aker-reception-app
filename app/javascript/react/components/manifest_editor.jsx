import React, { Fragment } from 'react'
import store from '../store'
import { Provider, connect } from 'react-redux'
import classNames from 'classnames'
import pluralize from 'pluralize'
import MappingTool from './mapping_tool'
import ManifestContainers from './manifest_containers'
import { uploadManifest, loadManifest, saveAndLeave, toggleMapping } from '../actions'
import StateSelectors from '../selectors'

import Reception from '../../routes.js.erb'

const MAX_UNCOLLAPSED_MESSAGES_TO_DISPLAY = 5

const logName = (name) => { }
const MessageDisplay = (props) => {
  logName('MessageDisplay')
  return (
    <span>At ({props.supplierPlateNames[props.labware_index]} - {props.address} {props.field}): {props.text}</span>
  )
}

const MessagesList = (props, messages, Renderer) => {
  logName('MessagesList')
  if (props.messages.length === 0) {
    return null
  }
  const cardId = `card-${props.type}`

  return (
    <div className={`card alert alert-${props.type}`} role="alert">
      <p className="card-header" data-toggle="collapse" data-target={"#"+cardId} style={{cursor: 'pointer'}}>
        {props.messages.length} {pluralize(((props.type=='danger') ? 'error' : props.type), props.messages.length)}:
      </p>
      <ul id={cardId} className={classNames({
        "card-body collapse": true,
        "show": (props.messages.length < MAX_UNCOLLAPSED_MESSAGES_TO_DISPLAY)
        })}>
        {
          props.messages.map((msg, pos) => {
            if (msg.labware_index && (props.selectedTabPosition != msg.labware_index)) {
              return
            }
            return (
              <li key={pos}>
                <p className='alert-msg'>&nbsp;
                  <MessageDisplay {...msg}
                    supplierPlateNames={props.supplierPlateNames}
                    selectedTabPosition={props.selectedTabPosition}
                    key={pos} />
                </p>
              </li>
            )
          })
        }
      </ul>
    </div>
  )
}


const MessagesDisplayComponent = (props) => {
  logName('MessagesDisplayComponent')
  return (
    <React.Fragment>
      <MessagesList {...props} messages={props.warnings} type="warning" />
      <MessagesList {...props} messages={props.errors} type="danger" />
    </React.Fragment>
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

const MappingButton = (props) => {
  if (!props.showMappingButton) {
    return null
  }
  return (
    <Fragment>
      <div className="row">&nbsp;</div>
      <div className="row">
        <button className="btn btn-primary" onClick={props.onShowMapping}>Show mapping</button>
      </div>
    </Fragment>
  )
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
          <div className="row">
            <label className="btn btn-primary">
                Browse for Manifest <ManifestUploader manifestId={manifestId} />
            </label>
          </div>
          <MappingButton {...props} />
        </div>
      </div>
    </div>
  )
}

const InformationDisplay = connect((state) => {
  return {
    manifestId: state.manifest.manifest_id,
    showHmdmcWarning: state.manifest.show_hmdmc_warning,
    showMappingButton: !!state.content.raw
  }
}, (dispatch, state) => {
  return {
    onShowMapping: () => { dispatch(toggleMapping(true)) }
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
