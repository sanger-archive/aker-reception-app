import React from "react"
import PropTypes from "prop-types"
import store from 'store'
import { Provider } from 'react-redux'
import MappingTool from './mapping_tool'

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
  render () {
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

const ManifestEditor = () => {
  return(
    <Provider store={store}>
      <ManifestEditorComponent />
    </Provider>
  )
}

export default ManifestEditor
