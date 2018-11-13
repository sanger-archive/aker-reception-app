import React from "react"
import PropTypes from "prop-types"
import store from 'store'
import { Provider, connect } from 'react-redux'
import MappingTool from './mapping_tool'
import {uploadManifest} from '../actions'

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

const Containers = () => { return (<div></div>) }


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
        <Containers />
      </div>
    )
  }
}


const mapStateToProps = (state) => {
  return {
    schema: state ? state.schema : null
  }
}

const mapDispatchToProps = (dispatch, { match, location }) => {
  return {
  }
}

let ManifestEditorConnected = connect(mapStateToProps, mapDispatchToProps)(ManifestEditorComponent)

const ManifestEditor = () => {
  $(document.body).on('uploadedmanifest', $.proxy(function(event, response) {
    /*if (response.contents.manifest.mapping.expected.length > 0) {
      $('#myModal').modal('show')
    }*/

    store.dispatch(uploadManifest(response))
    if (store.getState().mapping.shown) {
      $('#myModal').modal('show')
    }
  }, this))

  return(
    <Provider store={store}>
      <ManifestEditorConnected />
    </Provider>
  )
}

export { ManifestEditorConnected }

export default ManifestEditor
