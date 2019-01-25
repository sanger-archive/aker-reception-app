import React from 'react'
import PropTypes from 'prop-types'
import { connect } from 'react-redux'
import StateSelectors from '../selectors'
import { setManifestValue, saveTab, updateScientificName } from '../actions'
import { debounce } from 'throttle-debounce'

const logName = (name) => { }

const DEBOUNCED_TIMING = 500

export const LabwareContentSelectComponent = (props) => {
  logName('LabwareContentSelectComponent')
  const { title, name, id, selectedOptionValue, onChange } = props

  return (
    <select onChange={onChange} className="form-control" title={title} name={name} id={id} value={selectedOptionValue}>
      <option value=""></option>
      { props.optionsForSelect.map((val, pos) => {
        return (<option key={pos} value={val}>{val}</option>)
      }) }
    </select>
  )
}

LabwareContentSelectComponent.propTypes = {
  title: PropTypes.string.isRequired,
  name: PropTypes.string.isRequired,
  id: PropTypes.string.isRequired,
  selectedOptionValue: PropTypes.string.isRequired,
  onChange: PropTypes.func.isRequired,
  optionsForSelect: PropTypes.array.isRequired
}

export const LabwareContentSelect = connect((state, ownProps) => {
  return {
    selectedOptionValue: StateSelectors.schema.selectedOptionValue(state, ownProps.fieldName, ownProps.selectedValue),
    optionsForSelect: StateSelectors.schema.optionsForSelect(state, ownProps.fieldName)
  }
})(LabwareContentSelectComponent)

export const LabwareContentText = (props) => {
  logName('LabwareContentText')
  const { onChange, selectedValue, title, name, id } = props
  return (
    <input onChange={onChange}
      className="form-control" title={title} name={name} id={id}
      value={selectedValue} />
  )
}

LabwareContentText.propTypes = {
  onChange: PropTypes.func.isRequired,
  selectedValue: PropTypes.string.isRequired,
  title: PropTypes.string.isRequired,
  name: PropTypes.string.isRequired,
  id: PropTypes.string.isRequired
}

class LabwareContentInputComponent extends React.Component {
  constructor (props) {
    super(props)
    this.state = {
      value: props.selectedValue,
      stateValueSelected: 'redux'
    }
    this.onChangeProcessThrottelledCall = this.buildThrottelledCall()
  }

  setStateValueSelected (str) {
    this.setState({ stateValueSelected: str })
  }

  onChangeProcess (receivedChanges) {
    receivedChanges.reduceRight((memo, receivedChange) => {
      const found = (memo.filter((actualChange) => {
        return ((actualChange[0] === receivedChange[0]) && (actualChange[1] === receivedChange[1]) && (actualChange[2] === receivedChange[2]))
      }))
      if (found.length === 0) {
        memo.push(receivedChange)
      }
      return memo
    }, []).reverse().forEach((receivedChange, pos) => {
      this.props.onChangeManifestInput.apply(this, receivedChange)
    })

    // this.setStateValueSelected('redux')
    this.setState({ stateValueSelected: 'redux', value: this.props.selectedValue })
    this.receivedChanges = []
  }

  buildThrottelledCall () {
    let receivedChanges = []

    const debouncedCall = debounce(DEBOUNCED_TIMING, () => { this.onChangeProcess(receivedChanges) })

    return (labwareIndex, address, fieldName, value, plateId, taxonomyServiceUrl) => {
      this.setState({ stateValueSelected: 'react' })
      // this.setStateValueSelected('react')
      receivedChanges.push([labwareIndex, address, fieldName, value, plateId, taxonomyServiceUrl])
      debouncedCall()
    }
  }

  buildOnChangeManifestInput (labwareIndex, address, fieldName, plateId, taxonomyServiceUrl) {
    if (!this.onChange) {
      this.onChange = (e) => {
        const value = e.target.value
        this.setState({ value: value })
        this.onChangeProcessThrottelledCall(labwareIndex, address, fieldName, value, plateId, taxonomyServiceUrl)
      }
    }
    return this.onChange
  }

  commonPropsForInput () {
    // If we are in React mode, we'll get the value from the state of this component. If we are working in Redux mode
    /// we'll get it from Redux state
    const selectedValue = (this.state.stateValueSelected === 'react') ? this.state.value : this.props.selectedValue

    const { title, name, id, labwareIndex, address, fieldName, plateId, taxonomyServiceUrl } = this.props
    const onChange = this.buildOnChangeManifestInput(labwareIndex, address, fieldName, plateId, taxonomyServiceUrl)
    return { selectedValue, title, name, id, onChange }
  }

  render () {
    logName('LabwareContentInputComponent')
    const { isSelect, fieldName } = this.props
    if (isSelect) {
      return <LabwareContentSelect {...this.commonPropsForInput()} fieldName={fieldName} />
    } else {
      return <LabwareContentText {...this.commonPropsForInput()} />
    }
  }
}

LabwareContentInputComponent.propTypes = {
  selectedValue: PropTypes.string.isRequired,
  onChangeManifestInput: PropTypes.func.isRequired,
  title: PropTypes.string.isRequired,
  name: PropTypes.string.isRequired,
  id: PropTypes.string.isRequired,
  labwareIndex: PropTypes.string.isRequired,
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
      title: StateSelectors.schema.friendlyNameFor(state, ownProps.fieldName),
      name: `manifest[labware][${ownProps.labwareIndex}][contents][${ownProps.address}][${ownProps.fieldName}]`,
      id: `labware[${ownProps.labwareIndex}]address[${ownProps.address}]fieldName[${ownProps.fieldName}]`
    }
  },
  (dispatch, { match, location }) => {
    return {
      onChangeManifestInput: (labwareIndex, address, fieldName, value, plateId, taxonomyServiceUrl) => {
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
