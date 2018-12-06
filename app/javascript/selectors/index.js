import { createSelector } from 'reselect'

const StateAccessors = {
  manifest: {
    selectedTabPosition: createSelector(
      (state) => state?.manifest?.selectedTabPosition,
      (selectedTab) => { return parseInt(selectedTab, 10) }
    ),
    positionsForLabware: createSelector(
      (state, props) => state?.manifest?.labwares?.[props.labwareIndex],
      (labware) => labware?.positions
    ),
    supplierPlateNames: createSelector(
      (state) => state.manifest.labwares,
      (labwares) => labwares.map((l) => l.supplier_plate_name)
    ),
    plateIdFor: (state, pos) => StateAccessors.manifest.supplierPlateNames(state)[pos]
  },
  content: {
    hasTabMessages: createSelector(
      (state, labwareIndex) => StateAccessors.content.tabMessages(state, labwareIndex),
      (messages) => { return (messages.length > 0) }
    ),
    hasTabErrors: createSelector(
      (state, labwareIndex) => StateAccessors.content.errorTabMessages(state, labwareIndex),
      (messages) => { return (messages.length > 0) }
    ),
    isWarning: (m) => { return (m.level == 'WARN')},
    warningTabMessages: createSelector(
      (state, labwareIndex) => StateAccessors.content.tabMessages(state, labwareIndex),
      (messages) => messages.filter((m) => StateAccessors.content.isWarning(m))
    ),
    errorTabMessages: createSelector(
      (state, labwareIndex) => StateAccessors.content.tabMessages(state, labwareIndex),
      (messages) => messages.filter((m) => !StateAccessors.content.isWarning(m))
    ),
    tabMessages: (state, tabIndex) => {
      let val = state?.content?.structured?.messages?.filter((m) => m.labware_index==tabIndex)
      return (val ? val : [])
    },

    inputMessages: (state, props) => {
      return StateAccessors.content.tabMessages(state, props.labwareIndex).filter((m) => {
        return ((m.labware_index == props.labwareIndex) && (m.address == props.address) && (m.field==props.fieldName))
      })
    },

    errorInputMessages: createSelector(
      (state, props) => StateAccessors.content.inputMessages(state,props),
      (messages) => messages.filter((m) => !StateAccessors.content.isWarning(m))
    ),

    warningInputMessages: createSelector(
      (state, props) => StateAccessors.content.inputMessages(state,props),
      (messages) => messages.filter((m) => StateAccessors.content.isWarning(m))
    ),

    hasInputMessages: createSelector(
      (state, props) => StateAccessors.content.inputMessages(state,props),
      (messages) => (messages.length > 0)
    ),

    hasInputErrors: createSelector(
      (state, props) => StateAccessors.content.errorInputMessages(state,props),
      (messages) => (messages.length > 0)
    ),

    selectedValueAtCell: (state, labwareId, address, fieldName) => {
      const val = state?.content?.structured?.labwares?.[labwareId]?.addresses?.[address]?.fields?.[fieldName]?.value
      return (val ? val : "")
    },
    setValueAtCell: (state, labwareId, address, fieldName, value) => {
      let obj = ['content', 'structured', 'labwares', labwareId, 'addresses', address, 'fields', fieldName].reduce((memo, key) => {
        if (!memo[key]) {
          memo[key] = {}
        } /*else {
          memo[key] = Object.assign({}, memo[key])
        }*/
        return memo[key]
      }, Object.assign({}, state))
      obj.value = value
      return obj
    }
  },
  schema: {
    fieldsToShow: (state) => {
      return state.schema.show_on_form || []
    },
    friendlyNameFor: (state, fieldName) => {
      return (state.schema.properties[fieldName].friendly_name || fieldName)
    },
    isRequiredField: (state, fieldName) => {
      return StateAccessors.schema.propertyForFieldName(state, fieldName)["required"]
    },
    propertyForFieldName: (state, fieldName) => {
      return state.schema["properties"][fieldName]
    },
    fieldTypeFor: (state, fieldName)=> {
      return (state.schema["properties"][fieldName]["field_type"] || 'text')
    },
    fieldNameForPos: (state, pos) => {
      return state.schema.show_on_form[pos]
    },
    isSelectFieldName: (state, fieldName) => {
      return !!StateAccessors.schema.optionsForSelect(state, fieldName)
    },
    optionsForSelect: (state, fieldName) => {
      return state.schema.properties[fieldName]['allowed']
    },
    selectedOptionValue: (state, fieldName, selectedValue) => {
      if ((!selectedValue) || (selectedValue.length==0)) {
        return ""
      }
      return StateAccessors.schema.optionsForSelect(state, fieldName).filter((o) => {
        return o.match(new RegExp(selectedValue, 'i'))
      })[0] || ""
    }
  }
}

export default StateAccessors
