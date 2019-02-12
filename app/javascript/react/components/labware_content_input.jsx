import React from 'react'
import PropTypes from 'prop-types'
import { connect } from 'react-redux'
import StateSelectors from '../selectors'
import { setManifestValue, saveTab, updateScientificName } from '../actions'
import { debounce } from 'throttle-debounce'

const logName = (name) => {  }

const DEBOUNCED_TIMING = 500

class LabwareContentInputDefaultValue extends React.Component {
  constructor(props) {
    super(props)
    this.input = React.createRef();
  }
  setupInputValue(selectedValue) {
    if (this.input.current) {
      // By doing this we overwrite the contents of the input when we update the redux state without
      // rerendering the full DOM tree on every keystroke
      this.input.current.value=selectedValue
    }
  }
}


export class LabwareContentSelectComponent extends LabwareContentInputDefaultValue {
  render() {
    const props = this.props
    logName('LabwareContentSelectComponent')

    const { title, name, id, selectedOptionValue, onBlur, onChange, readOnly } = props
    this.setupInputValue(selectedOptionValue)

    return (
      <select ref={this.input}
        readOnly={readOnly} onBlur={onBlur} onChange={onChange}
        className="form-control" title={title} name={name} id={id} defaultValue={selectedOptionValue}>
        <option value=""></option>
        { props.optionsForSelect.map((val, pos) => {
          return (<option key={pos} value={val}>{val}</option>)
        }) }
      </select>
    )
  }
}

LabwareContentSelectComponent.propTypes = {
  onBlur: PropTypes.func.isRequired,
  onChange: PropTypes.func.isRequired,
  title: PropTypes.string.isRequired,
  name: PropTypes.string.isRequired,
  id: PropTypes.string.isRequired,
  selectedOptionValue: PropTypes.string.isRequired,
  optionsForSelect: PropTypes.array.isRequired
}

export const LabwareContentSelect = connect((state, ownProps) => {
  return {
    selectedOptionValue: StateSelectors.schema.selectedOptionValue(state, ownProps.fieldName, ownProps.selectedValue),
    optionsForSelect: StateSelectors.schema.optionsForSelect(state, ownProps.fieldName)
  }
})(LabwareContentSelectComponent)

export class LabwareContentText extends LabwareContentInputDefaultValue {
  render() {


    logName('LabwareContentText')
    // Because we dont want to send a request in every keystroke, we dont use the onChange handler
    const { onBlur, selectedValue, title, name, id, readOnly } = this.props
    this.setupInputValue(selectedValue)

    return (
      <input
        ref={this.input}
        defaultValue={selectedValue}
        onBlur={onBlur}
        readOnly={readOnly}
        tabIndex={readOnly ? "-1" : ""}
        className="form-control" title={title} name={name} id={id} />
    )
  }
}

LabwareContentText.propTypes = {
  onBlur: PropTypes.func.isRequired,
  onChange: PropTypes.func,
  selectedValue: PropTypes.string.isRequired,
  title: PropTypes.string.isRequired,
  name: PropTypes.string.isRequired,
  id: PropTypes.string.isRequired
}


class LabwareContentInputComponent extends React.Component {
  constructor (props) {
    super(props)
    this.state = {
      value: props.selectedValue
    }
    this.debouncedUpdateInput = debounce(DEBOUNCED_TIMING, () => {
      this.props.updateInput.apply(this, this.dataForUpdate)
    })
  }

  buildDirectUpdateInputHandler (labwareIndex, address, fieldName, plateId, taxonomyServiceUrl) {
    return (e) => {
      const value = e.target.value
      this.props.updateInput(labwareIndex, address, fieldName, value, plateId, taxonomyServiceUrl)
    }
  }

  buildDebouncedUpdateInputHandler (labwareIndex, address, fieldName, plateId, taxonomyServiceUrl) {
    return (e) => {
      const value = e.target.value
      this.dataForUpdate = [labwareIndex, address, fieldName, value, plateId, taxonomyServiceUrl]

      this.debouncedUpdateInput()
    }
  }

  commonPropsForInput () {
    let selectedValue = this.props.selectedValue
    const { title, name, id, labwareIndex, address, fieldName, plateId, taxonomyServiceUrl, readOnly } = this.props

    const onBlur = this.buildDirectUpdateInputHandler(labwareIndex, address, fieldName, plateId, taxonomyServiceUrl)
    const onChange = this.buildDebouncedUpdateInputHandler(labwareIndex, address, fieldName, plateId, taxonomyServiceUrl)

    return { selectedValue, title, name, id, onBlur, onChange, readOnly }
  }

  render () {
    logName('LabwareContentInputComponent')
    const { isSelect, fieldName, selectedValue, readOnly } = this.props
    if (isSelect) {
      return <fieldset disabled={readOnly}><LabwareContentSelect {...this.commonPropsForInput()} fieldName={fieldName} /></fieldset>
    } else {
      return <fieldset disabled={readOnly}><LabwareContentText {...this.commonPropsForInput()} /></fieldset>
    }
  }
}

LabwareContentInputComponent.propTypes = {
  selectedValue: PropTypes.string.isRequired,
  //onBlur: PropTypes.func.isRequired,
  title: PropTypes.string.isRequired,
  name: PropTypes.string.isRequired,
  id: PropTypes.string.isRequired,
  labwareIndex: PropTypes.number.isRequired,
  address: PropTypes.string.isRequired,
  plateId: PropTypes.string.isRequired,
  taxonomyServiceUrl: PropTypes.string.isRequired,
  isSelect: PropTypes.bool.isRequired,
  fieldName: PropTypes.string.isRequired
}

export const LabwareContentInput = connect(
  (state, ownProps) => {
    return {
      labwareIndex: ownProps.labwareIndex,
      address: ownProps.address,
      fieldName: ownProps.fieldName,

      taxonomyServiceUrl: state.services.taxonomy_service_url,

      plateId: StateSelectors.manifest.plateIdFor(state, ownProps.labwareIndex),

      selectedValue: StateSelectors.content.selectedValueAtCell(state, ownProps.labwareIndex, ownProps.address, ownProps.fieldName),
      isSelect: StateSelectors.schema.isSelectFieldName(state, ownProps.fieldName),
      readOnly: !StateSelectors.schema.isEditableField(state, ownProps.fieldName),
      title: StateSelectors.schema.friendlyNameFor(state, ownProps.fieldName),
      name: `manifest[labware][${ownProps.labwareIndex}][contents][${ownProps.address}][${ownProps.fieldName}]`,
      id: `labware[${ownProps.labwareIndex}]address[${ownProps.address}]fieldName[${ownProps.fieldName}]`
    }
  },
  (dispatch, { match, location }) => {
    return {
      updateInput: (labwareIndex, address, fieldName, value, plateId, taxonomyServiceUrl) => {
        dispatch(setManifestValue(labwareIndex, address, fieldName, value, plateId))
        if (fieldName === 'taxon_id') {
          let promise = dispatch(updateScientificName(labwareIndex, address, 'scientific_name', value, plateId, taxonomyServiceUrl))
          if (promise) {
            promise.then(() => {
              dispatch(saveTab())
            })
            return
          }
        }
        dispatch(saveTab())
      }
    }
  })(LabwareContentInputComponent)
