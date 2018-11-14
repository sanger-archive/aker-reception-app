import React from "react"
import PropTypes from "prop-types"
import { connect } from 'react-redux'

class ManifestContainersComponent extends React.Component {
  constructor(props) {
    super(props)
    this.state = {}
  }
  render() {
    return(
      <div>
      </div>
    )
  }
}

const mapStateToProps = (state) => {
  return {
  }
}

const mapDispatchToProps = (dispatch, { match, location }) => {
  return {
  }
}

let ManifestContainersConnected = connect(mapStateToProps, mapDispatchToProps)(ManifestContainersComponent)

export default ManifestContainersConnected
