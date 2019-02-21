import React, {Fragment} from "react"
import PropTypes from "prop-types"
import { connect } from 'react-redux'
import classNames from 'classnames'
import {saveTab} from '../actions'

const StoreManagerComponent = (props) => {
  return (
    <span onClick={props.savingAction}
      className={
        classNames({
          "fas fa-spinner": true,
          "fa-spin visible": (props.isSaving),
          "invisible": (!props.isSaving)
        })
      }>
    </span>
  )
}

const StoreManager = connect((status) => {
  return {
    isSaving: !!status.content.savingRequest
  }
}, (dispatch) => {
  return {
    savingAction: () => { dispatch(saveTab()) }
  }
})(StoreManagerComponent)

export default StoreManager
