import React from "react"
import PropTypes from "prop-types"
import store from 'store'
import { Provider, connect } from 'react-redux'
import MappingTool from './mapping_tool'
import ManifestContainers from './manifest_containers'
import { loadManifest, selectExpectedOption, selectObservedOption, displayMessage} from '../actions'
import StateSelectors from '../selectors'

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


export const ManifestEditorComponent = (props) => {
  logName('ManifestEditorComponent')
  return(
    <div>
      <MappingTool />
      <MessagesDisplay />
      <ManifestContainers />
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
