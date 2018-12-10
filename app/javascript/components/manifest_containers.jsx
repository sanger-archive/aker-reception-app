import React from "react"
import {Fragment} from "react"
import PropTypes from "prop-types"
import { connect } from 'react-redux'
import StateSelectors from '../selectors'
import { setManifestValue} from '../actions'

import LabwareTabs from './labware_tabs'
import classNames from 'classnames'

import { unstable_trace as trace } from "scheduler/tracing";

const logName = (name) => { }

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
    friendlyName: StateSelectors.schema.friendlyNameFor(state, ownProps.fieldName),
    isRequiredField: StateSelectors.schema.isRequiredField(state, ownProps.fieldName)
  }
})(LabwareContentHeaderComponent)

const LabwareContentSelectComponent = (props) => {
  logName('LabwareContentSelectComponent')
  const {fieldName,title,name,id,selectedOptionValue,onChange} = props

  return(
    <select onChange={onChange} className="form-control" title={title} name={name} id={id} value={selectedOptionValue}>
      <option value=""></option>
      { props.optionsForSelect.map((val, pos) => {
        return (<option key={pos} value={val}>{val}</option>)
      }) }
    </select>
  )
}

const LabwareContentSelect = connect((state, ownProps) => {
  return {
    selectedOptionValue: StateSelectors.schema.selectedOptionValue(state, ownProps.fieldName, ownProps.selectedValue),
    optionsForSelect: StateSelectors.schema.optionsForSelect(state, ownProps.fieldName)
  }
})(LabwareContentSelectComponent)

const LabwareContentText = (props) => {
  logName('LabwareContentText')
  const {onChange,selectedValue,title,name,id} = props
  return(
    <input onChange={onChange}
      className="form-control" title={title} name={name} id={id}
      value={selectedValue} />
  )
}

class LabwareContentInputComponent extends React.Component {
  constructor(props) {
    super(props)
  }

  buildOnChangeManifestInput(labwareIndex, address, fieldName, plateId) {
    if (!this.onChange) {
      this.onChange = (e) => {


        trace("Change input", performance.now(), () => {
          return this.props.onChangeManifestInput(labwareIndex, address, fieldName, e.target.value, plateId)
        });
        //return this.props.onChangeManifestInput(labwareIndex, address, fieldName, e.target.value, plateId)
      }
    }
    return this.onChange
  }

  commonPropsForInput() {
    const { title, name, id, selectedValue, labwareIndex, address, fieldName, plateId } = this.props
    const onChange = this.buildOnChangeManifestInput(labwareIndex, address, fieldName, plateId)
    return { selectedValue, title, name, id, onChange }
  }

  render() {
    logName('LabwareContentInputComponent')
    const {isSelect, fieldName} = this.props
    if (isSelect) {
      return <LabwareContentSelect {...this.commonPropsForInput()} fieldName={fieldName} />
    } else {
      return <LabwareContentText {...this.commonPropsForInput()} />
    }
  }
}

const LabwareContentInput = connect(
  (state, ownProps) => {
    return {
      labwareIndex: ownProps.labwareIndex,
      address: ownProps.address,
      fieldName: ownProps.fieldName,

      plateId: StateSelectors.manifest.plateIdFor(state, ownProps.labwareIndex),

      selectedValue: StateSelectors.content.selectedValueAtCell(state, ownProps.labwareIndex, ownProps.address, ownProps.fieldName),
      isSelect: StateSelectors.schema.isSelectFieldName(state, ownProps.fieldName),
      title: StateSelectors.schema.friendlyNameFor(state, ownProps.fieldName),
      name: `manifest[labware][${ownProps.labwareIndex}][contents][${ownProps.address}][${ownProps.fieldName}]`,
      id: `labware[${ownProps.labwareIndex}]address[${ownProps.address}]fieldName[${ownProps.fieldName}]`
      }
  },
  (dispatch, { match, location }) => {
    return {
      onChangeManifestInput: (labwareIndex, address, fieldName, value, plateId) => {
        dispatch(setManifestValue(labwareIndex, address, fieldName, value, plateId))
      }
    }
  })(LabwareContentInputComponent)

class LabwareContentCellComponent extends React.Component {
  /*shouldComponentUpdate(nextProps, nextState) {
    const val = StateSelectors.content.selectedValueAtCell(this.state, this.props.labwareIndex, this.props.address, this.props.fieldName)
    const nextVal = StateSelectors.content.selectedValueAtCell(nextState, nextProps.labwareIndex, nextProps.address, nextProps.fieldName)
    return (val !== nextVal)
  }*/
  render() {
    logName('LabwareContentCellComponent')
    const props = this.props
    return (
      <td data-psd-schema-validation-name={props.fieldName}>
        <div className={ classNames({
                'form-group': true,
                'has-error': props.displayError,
                'has-warning': props.displayWarning
              }
            )
          }
          style={{position: "relative"}}>

          <LabwareContentInput
            labwareIndex={props.labwareIndex}
            address={props.address}
            fieldName={props.fieldName} />
        </div>
      </td>
    )
  }
}

const LabwareContentCell = connect((state, ownProps) => {
  const contentAccessor = StateSelectors.content
  const hasMessages = contentAccessor.hasInputMessages(state, ownProps)
  const hasErrors = contentAccessor.hasInputErrors(state, ownProps)

  return {
    labwareIndex: ownProps.labwareIndex,
    address: ownProps.address,
    fieldName: ownProps.fieldName,
    displayError: hasMessages && hasErrors,
    displayWarning: hasMessages && !hasErrors
  }
})(LabwareContentCellComponent)

const LabwareContentAddressComponent = (props) => {
  logName('LabwareContentAddressComponent')
  return(
    <tr
      data-psd-component-class='TaxonomyIdControl'
      data-psd-component-parameters={
        JSON.stringify({
          taxonomyServiceUrl: props.taxonomyServiceUrl,
          relativeCssSelectorSciName: 'td[data-psd-schema-validation-name=scientific_name] input',
          relativeCssSelectorTaxId: 'td[data-psd-schema-validation-name=taxon_id] input',
          cachedTaxonomies: {}
        })
      }
      data-labware-index={ props.labwareIndex } data-address={ props.address }>
      <td>{ props.address }</td>

      {props.fieldsToShow.map((fieldName, pos) => {
        return <LabwareContentCell
          labwareIndex={props.labwareIndex}
          address={props.address} fieldName={fieldName}
                key={fieldName} />
      })}
    </tr>
  )
}

const LabwareContentAddress = connect((state, ownProps) => {
  return {
    labwareIndex: ownProps.labwareIndex,
    address: ownProps.address,

    fieldsToShow: StateSelectors.schema.fieldsToShow(state),
    taxonomyServiceUrl: state.services.taxonomy_service_url,
  }
})(LabwareContentAddressComponent)

class LabwareContentAddresses extends React.Component {
  shouldComponentUpdate(nextProps, nextState) {
    const update = (nextProps.selectedTabPosition == this.props.position)
    return update
  }
  render() {
    logName('LabwareContentAddresses')
    const props = this.props
    return props.positionsForLabware.map((address, posAddress) => {
      return (
        <LabwareContentAddress key={address}
          labwareIndex={props.position}
          address={address}  />
      )
    })
  }
}

const LabwareContentComponent = (props) => {
  logName('LabwareContentComponent')
  return(
    <div role="tabpanel"
      className={classNames({"tab-pane": true, "active": (props.selectedTabPosition === props.position)})}
      id={"Labware"+ props.labwareIndex}>

      <div style={{overflow: "scroll"}} className="material-data-table">

        <table className="table table-condensed table-striped"
               data-psd-component-class={
                JSON.stringify(["LoadTable", "DataTableSchemaValidation"])
              }
               data-psd-component-parameters={JSON.stringify([{
                manifest_id: props.manifestId
                }, {
                  schemaJson: props.schema,
                  material_schema_url: props.materialSchemaUrl
                }
                ])}>
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
            <LabwareContentAddresses
              positionsForLabware={props.positionsForLabware}
              selectedTabPosition={props.selectedTabPosition} position={props.position} />
          </tbody>
        </table>
      </div>
    </div>
  )
}

const LabwareContent = connect((state, ownProps) => {
  return {
    labwareIndex: ownProps.labwareIndex,

    schema: StateSelectors.schema.get(state),
    manifestId: state.manifest.manifest_id,
    selectedTabPosition: StateSelectors.manifest.selectedTabPosition(state),
    positionsForLabware: StateSelectors.manifest.positionsForLabware(state, ownProps.labwareIndex),
    materialSchemaUrl: state.services.materials_schema_url,
    fieldsToShow: StateSelectors.schema.fieldsToShow(state)
  }
})(LabwareContentComponent)

const LabwareContentsComponent = (props) => {
  logName('LabwareContentsComponent')
  return (
    <div className="tab-content">
      { props.labwareIndexes.map((labwareIndex, pos) => {
        return (
          <LabwareContent key={labwareIndex} labwareIndex={labwareIndex} position={pos} />
        )
      })}
    </div>
    )
}

const LabwareContents = connect((state) => {
  logName('LabwareContents')
  return {
    labwareIndexes: StateSelectors.manifest.labwareIndexes(state)
  }
})(LabwareContentsComponent)

const ManifestContainersComponent = (props) => {
  logName('ManifestContainersComponent')
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
