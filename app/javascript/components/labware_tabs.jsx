import React from "react"
import { connect } from 'react-redux'
import { StateAccessors } from '../lib/state_accessors'
import { changeTab, saveTab } from '../actions'

const LabwareTab = (props) => {
  const {position, supplierPlateName, selectedTabPosition} = props

  return(
    <li onClick={props.onClickTab} key={position}
        className={ (position == selectedTabPosition) ? 'active' : '' } role="presentation">
      <a data-toggle="tab"
         id={`labware_tab[${ position }]`}
         href={`#Labware${ position }`}
         aria-controls="Labware{ position }" role="tab">
          { (supplierPlateName) ? supplierPlateName : "Labware " + (position+1)  }
      </a>
      <input type="hidden" value={ supplierPlateName } name={`manifest[labware][${ position }][supplier_plate_name]`} />
    </li>
    )
}

const LabwareTabsComponent = (props) => {
  return(
    <ul data-labware-count={ props.supplierPlateNames.length } className="nav nav-tabs" role="tablist">
      { props.supplierPlateNames.map((supplierPlateName, position) => {
        return (
          <LabwareTab selectedTabPosition={props.selectedTabPosition}
            onClickTab={props.buildOnClickTab(position)}
            supplierPlateName={supplierPlateName} position={position} key={position}
            onClickTab={props.buildOnClickTab(position)} />
        )
      })}
    </ul>
  )
}

const LabwareTabs = connect((state) => {
  return {
    supplierPlateNames: StateAccessors(state).manifest.labwaresForManifest().map((l) => l.supplier_plate_name),
    selectedTabPosition: parseInt(state.manifest.selectedTabPosition, 10)
  }
}, (dispatch, ownProps) => {
  return {
    buildOnClickTab: (position) => {
      return () => {
        dispatch(changeTab(position))
        dispatch(saveTab())
      }
    }
  }
})(LabwareTabsComponent)

export default LabwareTabs
