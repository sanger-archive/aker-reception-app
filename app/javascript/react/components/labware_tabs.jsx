import React from 'react'
import { connect } from 'react-redux'
import StateSelectors from '../selectors'
import { changeTab, saveTab } from '../actions'
import classNames from 'classnames'

const logName = (name) => { }

class LabwareTabComponent extends React.Component {
  render () {
    logName('LabwareTabComponent')
    const { position, supplierPlateName, selectedTabPosition, displayError, displayWarning, buildOnClickTab } = this.props

    if (!this.onClickTab) {
      this.onClickTab = buildOnClickTab(position)
    }

    return (
      <li onClick={this.onClickTab} key={position}
        className={ classNames({ 'active': position === selectedTabPosition }) }
        role="presentation">
        <a data-toggle="tab"
          id={`labware_tab[${position}]`}
          href={`#Labware${position}`}
          className={ classNames({ 'bg-danger': displayError, 'bg-warning': displayWarning }) }
          aria-controls="Labware{ position }" role="tab">
          { (supplierPlateName) || 'Labware ' + (position + 1) }
        </a>
        <input type="hidden" value={ supplierPlateName } name={`manifest[labware][${position}][supplier_plate_name]`} />
      </li>
    )
  }
}

export const LabwareTab = connect(
  ((hasTabMessages, hasTabErrors) => {
    return (state, ownProps) => {
      const hasMessages = hasTabMessages(state, ownProps.position)
      const hasErrors = hasTabErrors(state, ownProps.position)
      return {
        displayError: hasMessages && hasErrors,
        displayWarning: hasMessages && !hasErrors
      }
    }
  })(StateSelectors.content.buildCheckTabMessages(), StateSelectors.content.buildCheckTabErrors()),
  (dispatch, ownProps) => {
    return {
      buildOnClickTab: (position) => {
        return () => {
          dispatch(changeTab(position))
          dispatch(saveTab())
        }
      }
    }
  })(LabwareTabComponent)

const LabwareTabsComponent = (props) => {
  logName('LabwareTabsComponent')
  return (
    <ul data-labware-count={ props.supplierPlateNames.length } className="nav nav-tabs" role="tablist">
      { props.supplierPlateNames.map((supplierPlateName, position) => {
        return (
          <LabwareTab selectedTabPosition={props.selectedTabPosition}
            supplierPlateName={supplierPlateName} position={position} key={position} />
        )
      })}
    </ul>
  )
}

const LabwareTabs = connect((state) => {
  logName('LabwareTabs')
  return {
    supplierPlateNames: StateSelectors.manifest.supplierPlateNames(state),
    selectedTabPosition: StateSelectors.manifest.selectedTabPosition(state)
  }
})(LabwareTabsComponent)

export default LabwareTabs
