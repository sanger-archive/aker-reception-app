import React from "react"
import PropTypes from "prop-types"
import store from 'store'
import { Provider, connect } from 'react-redux'
import MappingTool from './mapping_tool'

import C from '../constants'

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
    this.state = {mappingTool: {}}
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
    manifest: state ? state.manifest : {},
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
    if (response.contents.mapping_tool.expected.length > 0) {
      $('#myModal').modal('show')
    }
    this.dispatch({type: C.UPLOADED_MANIFEST, manifestData: response.contents})
  }, store))

  return(
    <Provider store={store}>
      <ManifestEditorConnected />
    </Provider>
  )
}

export { ManifestEditorConnected }

export default ManifestEditor
