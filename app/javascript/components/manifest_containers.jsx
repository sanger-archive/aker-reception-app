import React from "react"
import PropTypes from "prop-types"
import { connect } from 'react-redux'

const LabwareTab = (props) => {
  const position = props.labware_index

  return(
    <li className="{ (position == 0) ? 'active' : '' }" role="presentation">
      <a data-toggle="tab"
         id="labware_tab[{ position }]"
         href="#Labware{ position }"
         aria-controls="Labware{ position }" role="tab">
          { (props.supplier_plate_name) ? props.supplier_plate_name : "Labware " + position  }
      </a>
      <input type="hidden" value="{ manifestId }" name="manifest_id" />
      <input type="hidden" value="{ props.supplier_plate_name }" name="manifest[labware][{{ position }}][supplier_plate_name]" />
    </li>
    )
}

const LabwareTabs = (props) => {
  return(
      <ul data-labware-count="{{ keysForLabwares.length }}" className="nav nav-tabs" role="tablist">
      { props.manifest.labwares.map((labwareProps) => { return LabwareTab(labwareProps) })}
      </ul>
    )
}

class ManifestContainersComponent extends React.Component {
  constructor(props) {
    super(props)
    this.state = {}
  }
  render() {
    return(
      <LabwareTabs {...this.props} />
    )
  }
}

const mapStateToProps = (state) => {
  return state
}

const mapDispatchToProps = (dispatch, { match, location }) => {
  return {
  }
}

let ManifestContainersConnected = connect(mapStateToProps, mapDispatchToProps)(ManifestContainersComponent)

export default ManifestContainersConnected
