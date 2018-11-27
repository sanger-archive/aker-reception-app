import React from "react"
import {Fragment} from "react"
import PropTypes from "prop-types"
import { connect } from 'react-redux'
import { StateAccessors } from '../lib/state_accessors'
import { setManifestValue} from '../actions'

const LabwareTab = (props) => {
  const {position, supplierPlateName} = props

  return(
    <li key={position} className={ (position == 0) ? 'active' : '' } role="presentation">
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
          <LabwareTab supplierPlateName={supplierPlateName} position={position} key={position} />
        )
      })}
    </ul>
  )
}

const LabwareTabs = connect((state) => {
  return {
    supplierPlateNames: StateAccessors(state).manifest.labwaresForManifest().map((l) => l.supplier_plate_name)
  }
})(LabwareTabsComponent)

const LabwareContentHeaderComponent = (props) => {
  const requiredMark = props.isRequiredField ? (<span style={{color: "red"}}>*</span>) : null

  return(
    <th style={{whiteSpace: "nowrap"}}>
      { props.friendlyName }{ requiredMark }
    </th>
  )
}

const LabwareContentHeader = connect((state, ownProps) => {
  return {
    friendlyName: StateAccessors(state).schema.friendlyNameFor(ownProps.fieldName),
    isRequiredField: StateAccessors(state).schema.isRequiredField(ownProps.fieldName)
  }
})(LabwareContentHeaderComponent)

const LabwareContentSelectComponent = (props) => {
  const {fieldName,address,title,name,id,selectedValue} = props

  return(
    <select className="form-control" title={title} name={name} id={id} selected={selectedValue}>
      <option value=""></option>
      { props.optionsForSelect.map((val, pos) => {
        return (<option key={pos} value={val}>{val}</option>)
      }) }
    </select>
  )
}

const LabwareContentSelect = connect((state, ownProps) => {
  return { optionsForSelect: StateAccessors(state).schema.optionsForSelect(ownProps.fieldName) }
})(LabwareContentSelectComponent)

class LabwareContentTextComponent extends React.Component {
  constructor(props) {
    super(props)
  }

  render() {
    const {fieldName,supplierPlateName,address,selectedValue,title,name,id} = this.props
    return(
      <input onChange={this.buildOnChangeManifestInput(supplierPlateName, address, fieldName)}
        className="form-control" title={title} name={name} id={id}
        value={selectedValue} />
    )
  }
  buildOnChangeManifestInput(supplierPlateName, address, fieldName) {
    return (e) => {
      return this.props.onChangeManifestInput(supplierPlateName, address, fieldName, e.target.value)
    }
  }
}

const LabwareContentText = connect((state)=> { return {} }, (dispatch, { match, location }) => {
  return {
    onChangeManifestInput: (supplierPlateName, address, fieldName, value) => {
      dispatch(setManifestValue(supplierPlateName, address, fieldName, value))
    }
  }
})(LabwareContentTextComponent)

const LabwareContentInputComponent = (props) => {
  if (props.isSelect) {
    return <LabwareContentSelect {...props} />
  } else {
    return <LabwareContentText {... props} />
  }
}

const LabwareContentInput = connect((state, ownProps) => {
  return { isSelect: StateAccessors(state).schema.isSelectFieldName(ownProps.fieldName) }
})(LabwareContentInputComponent)

const LabwareContentCellComponent = (props) => {
  return (
    <td data-psd-schema-validation-name={props.fieldName}>
      <div className="form-group" style={{position: "relative"}}>
        <LabwareContentInput
          supplierPlateName={props.supplierPlateName} address={props.address} fieldName={props.fieldName}
          selectedValue={props.selectedValue}
          title={props.title} name={props.name} id={props.cellId} />
      </div>
    </td>
  )
}

const LabwareContentCell = connect((state, ownProps) => {
  return {
    fieldName: ownProps.fieldName,
    labwareIndex: ownProps.labwareIndex,
    supplierPlateName: ownProps.supplierPlateName,
    address: ownProps.address,
    title: StateAccessors(state).schema.friendlyNameFor(ownProps.fieldName),
    name: `manifest[labware][${ownProps.labwareIndex}][contents][${ownProps.address}][${ownProps.fieldName}]`,
    cellId: `labware[${ownProps.labwareIndex}]address[${ownProps.address}]fieldName[${ownProps.fieldName}]`,
    selectedValue: StateAccessors(state).content.selectedValueAtCell(ownProps.supplierPlateName, ownProps.address, ownProps.fieldName)
  }
})(LabwareContentCellComponent)

const LabwareContentAddressComponent = (props) => {
  return(
    <tr
      data-psd-component-class='TaxonomyIdControl'
      data-psd-component-parameters={
        {
          taxonomyServiceUrl: props.taxonomyServiceUrl,
          relativeCssSelectorSciName: 'td[data-psd-schema-validation-name=scientific_name] input',
          relativeCssSelectorTaxId: 'td[data-psd-schema-validation-name=taxon_id] input',
          cachedTaxonomies: {}
        }
      }
      data-labware-index={ props.labwareIndex } data-address={ props.address }>
      <td>{ props.address }</td>

      {props.fieldsToShow.map((fieldName, pos) => {
        return <LabwareContentCell
          supplierPlateName={props.supplierPlateName}
          labwareIndex={props.labwareIndex}
          address={props.address} fieldName={fieldName}
                key={fieldName} />
      })}
    </tr>
  )
}

const LabwareContentAddress = connect((state, ownProps) => {
  return {
    fieldsToShow: StateAccessors(state).schema.fieldsToShow(),
    taxonomyServiceUrl: state.services.taxonomy_service_url,
    labwareIndex: ownProps.labwareIndex,
    address: ownProps.address,
    supplierPlateName: ownProps.supplierPlateName
  }
})(LabwareContentAddressComponent)

const LabwareContentComponent = (props) => {
  return(
    <div role="tabpanel" className="tab-pane" id={"Labware"+ props.labwareIndex}>

      <div style={{overflow: "scroll"}} className="material-data-table">

      <table className="table table-condensed table-striped"
             data-psd-component-class={JSON.stringify(["LoadTable", "DataTableSchemaValidation"])}
             data-psd-component-parameters={[{
              manifest_id: props.manifestId
              }, {
                material_schema_url: props.materialSchemaUrl
              }
              ]}>
        <thead>
          <tr>
            <th></th>
            { props.fieldsToShow.map((name, pos) => {
              return (
                <LabwareContentHeader fieldName={name} key={name} />
            )})}
          </tr>
        </thead>

        <tbody>
            { props.positionsForLabware.map((address, posAddress) => {
              return (
                <LabwareContentAddress key={address}
                  supplierPlateName={props.supplierPlateName}
                  labwareIndex={props.labwareIndex}
                  address={address}  />
            )}) }
          </tbody>
        </table>
      </div>
    </div>
  )
}

const LabwareContent = connect((state, ownProps) => {
  const labware = StateAccessors(state).manifest.labwareAtIndex(ownProps.labwareIndex)
  return {
    manifestId: state.manifest.manifest_id,
    labwareIndex: ownProps.labwareIndex,
    supplierPlateName: labware.supplier_plate_name,
    positionsForLabware: labware.positions,
    materialSchemaUrl: state.services.materials_schema_url,
    fieldsToShow: StateAccessors(state).schema.fieldsToShow()
  }
})(LabwareContentComponent)

const LabwareContentsComponent = (props) => {
  return (
    <div className="tab-content">
      { props.labwareIndexes.map((labwareIndex, pos) => {
        return (
          <LabwareContent key={labwareIndex} labwareIndex={labwareIndex} />
        )
      })}
    </div>
    )
}

const LabwareContents = connect((state) => {
  return {
    labwareIndexes: StateAccessors(state).manifest.labwaresForManifest().map((labware,pos) => pos)
  }
})(LabwareContentsComponent)

const ManifestContainersComponent = (props) => {
  if (props.manifestId) {
    return(
      <Fragment>
        <input type="hidden" value={ props.manifestId } name="manifest_id" />
        <LabwareTabs />
        <LabwareContents />
      </Fragment>
    )
  } else {
    return null
  }
}

const ManifestContainers = connect((state) => {
  return { manifestId: state.manifest.manifest_id }
})(ManifestContainersComponent)

export default ManifestContainers
