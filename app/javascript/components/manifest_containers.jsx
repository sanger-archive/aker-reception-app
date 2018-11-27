import React from "react"
import {Fragment} from "react"
import PropTypes from "prop-types"
import { connect } from 'react-redux'
import { StateAccessors } from '../lib/state_accessors'
import { setManifestValue} from '../actions'

const LabwareTab = (props) => {
  const {position} = props

  return(
    <li key={position} className={ (position == 0) ? 'active' : '' } role="presentation">
      <a data-toggle="tab"
         id={`labware_tab[${ position }]`}
         href={`#Labware${ position }`}
         aria-controls="Labware{ position }" role="tab">
          { (props.supplier_plate_name) ? props.supplier_plate_name : "Labware " + (position+1)  }
      </a>
      <input type="hidden" value={ props.supplier_plate_name } name={`manifest[labware][${ position }][supplier_plate_name]`} />
    </li>
    )
}

const LabwareTabs = (props) => {
  return(
    <ul data-labware-count={ StateAccessors(props).manifest.labwaresForManifest().length } className="nav nav-tabs" role="tablist">
      <input type="hidden" value={ props.manifest.manifest_id } name="manifest_id" />
      { StateAccessors(props).manifest.labwaresForManifest().map((labwareProps, position) => {
        return (
          <LabwareTab {...labwareProps} position={position} key={position} />
        )
      })}
    </ul>
  )
}


const LabwareContentHeader = (props) => {
  const {fieldName} = props
  const friendlyName = StateAccessors(props).schema.friendlyNameFor(fieldName)
  const requiredMark = StateAccessors(props).schema.isRequiredField(fieldName) ? (<span style={{color: "red"}}>*</span>) : null

  return(
    <th style={{whiteSpace: "nowrap"}}>
      { friendlyName }{ requiredMark }
    </th>
  )
}

const LabwareContentSelect = (props) => {
  const {labware,fieldName,address,title,name,id,selectedValue} = props

  return(
    <select className="form-control" title={title} name={name} id={id} selected={selectedValue}>
      <option value=""></option>
      { StateAccessors(props).schema.optionsForSelect(fieldName).map((val, pos) => { return (<option key={pos} value={val}>{val}</option>)}) }
    </select>
  )
}

const LabwareContentText = (props) => {
  const {fieldName,labware,address,selectedValue,title,name,id} = props
  return(
    <input onChange={props.buildOnChangeManifestInput(labware.supplier_plate_name, address, fieldName)} className="form-control" title={title} name={name} id={id}
      value={selectedValue} />
  )
}

const LabwareContentInput = (props) => {
  const {fieldName} = props
  if (StateAccessors(props).schema.isSelectFieldName(fieldName)) {
    return <LabwareContentSelect {...props} />
  } else {
    return <LabwareContentText {... props} />
  }
}

const LabwareContentCell = (props) => {
  const {labware, address, fieldName} = props

  const title=StateAccessors(props).schema.friendlyNameFor(fieldName)
  const name=`manifest[labware][${labware.labware_index}][contents][${address}][${fieldName}]`
  const id=`labware[${labware.labware_index}]address[${address}]fieldName[${fieldName}]`
  const selectedValue = StateAccessors(props).content.selectedValueAtCell(labware.supplier_plate_name, address, fieldName)
  return (
    <td data-psd-schema-validation-name={fieldName}>
      <div className="form-group" style={{position: "relative"}}>
        <LabwareContentInput {...props}
          selectedValue={selectedValue}
          title={title} name={name} id={id} />
      </div>
    </td>
  )
}

const LabwareContentAddress = (props) => {
  const {labware, address} = props
  return(
    <tr
      data-psd-component-class='TaxonomyIdControl'
      data-psd-component-parameters={
        {
          taxonomyServiceUrl: props.services.taxonomy_service_url,
          relativeCssSelectorSciName: 'td[data-psd-schema-validation-name=scientific_name] input',
          relativeCssSelectorTaxId: 'td[data-psd-schema-validation-name=taxon_id] input',
          cachedTaxonomies: {}
        }
      }
      data-labware-index={ labware.labware_index } data-address={ address }>
      <td>{ address }</td>

      {StateAccessors(props).schema.fieldsToShow().map((fieldName, pos) => {
        return <LabwareContentCell {...props} fieldName={fieldName} key={pos} address={address} />
      })}
    </tr>
  )
}

const LabwareContent = (props) => {
  const {labware} = props
  return(
    <div role="tabpanel" className="tab-pane" id={"Labware"+ labware.labware_index}>

      <div style={{overflow: "scroll"}} className="material-data-table">

      <table className="table table-condensed table-striped"
             data-psd-component-class={JSON.stringify(["LoadTable", "DataTableSchemaValidation"])}
             data-psd-component-parameters={[{
              manifest_id: props.manifest.manifest_id
              }, {
                material_schema_url: props.services.materials_schema_url
              }
              ]}>
        <thead>
          <tr>
            <th></th>
            { StateAccessors(props).schema.fieldsToShow().map((name, pos) => {
              return (
                <LabwareContentHeader {...props} key={pos} fieldName={name} />
            )})}
          </tr>
        </thead>

        <tbody>
            { StateAccessors(props).manifest.positionsForLabware(labware).map((address, posAddress) => {
              return (
                <LabwareContentAddress {...props} key={posAddress} address={address}  />
            )}) }
          </tbody>
        </table>
      </div>
    </div>
  )
}

const LabwareContents = (props) => {
  return (
    <div className="tab-content">
      { StateAccessors(props).manifest.labwaresForManifest().map((labware, pos) => {
        return (
          <LabwareContent {...props} key={pos} labware={labware} />
          )
      })}
    </div>
    )
}

class ManifestContainersComponent extends React.Component {
  constructor(props) {
    super(props)
    this.state = {}
  }
  render() {
    if (this.props.manifest) {
      return(
        <Fragment>
          <LabwareTabs {...this.props} />
          <LabwareContents {...this.props} />
        </Fragment>
      )
    } else {
      return null
    }
  }
}

const mapStateToProps = (state) => {
  { manifest: state.manifest }
}

const mapDispatchToProps = (dispatch, { match, location }) => {
  return {
      buildOnChangeManifestInput: (labwareId, address, fieldName) => {
        return (e) => {
          dispatch(setManifestValue(labwareId, address, fieldName, e.target.value))
        }
      }
  }
}

let ManifestContainersConnected = connect(mapStateToProps, mapDispatchToProps)(ManifestContainersComponent)

export default ManifestContainersConnected
