import React from "react"
import PropTypes from "prop-types"
import store from 'store'
import { Provider, connect } from 'react-redux'
import MappingTool from './mapping_tool'
import ManifestContainers from './manifest_containers'
import { loadManifest, selectExpectedOption, selectObservedOption} from '../actions'

const ErrorsDisplay = () => {
  return (
    <div id="page-error-alert" className="alert alert-danger hidden" role="alert">
      <button type="button" className="close" aria-label="Close"><span aria-hidden="true">&times;</span></button>
      <p className='alert-msg'>&nbsp;</p>
    </div>
    )
}

const WarningsDisplay = () => {
  return (
    <div id="page-warning-alert" className="alert alert-warning hidden" role="alert">
      <strong className='alert-title'>Warning!</strong>
      <p className='alert-msg'>&nbsp;</p>
    </div>
  )
}


class ManifestEditorComponent extends React.Component {
  constructor(props) {
    super(props)
    this.state = {mapping: {}}
  }
  render() {
    return(
      <div>
        <ErrorsDisplay />
        <WarningsDisplay />
        <MappingTool />
        <ManifestContainers />
      </div>
    )
  }
}


const mapStateToProps = (state) => {
  return state
  /*return {
    schema,
    manifest,
    mapping,
    content
    schema: state ? state.schema : null,
    schema: state ? state.schema : null
  }*/
}

const mapDispatchToProps = (dispatch, { match, location }) => {
  return {
  }
}

let ManifestEditorConnected = connect(mapStateToProps, mapDispatchToProps)(ManifestEditorComponent)

const ManifestEditor = (props) => {
  if (props) {
    store.dispatch(loadManifest(props))
  }
  $(document.body).on('uploadedmanifest', $.proxy(function(event, response) {
    const manifest = response.contents

    store.dispatch(loadManifest(manifest))
    //store.dispatch(loadManifestMapping(manifest.mapping))
    console.log(store.getState())
    if (store.getState().mapping.shown) {
      store.dispatch(selectExpectedOption(null))
      store.dispatch(selectObservedOption(null))

      $('#myModal').modal('show')
    } else {
      //store.dispatch(loadManifestContent(manifest.content))
    }
  }, this))

  return(
    <Provider store={store}>
      <ManifestEditorConnected {...props} />
    </Provider>
  )
}

export { ManifestEditorConnected }

export default ManifestEditor
