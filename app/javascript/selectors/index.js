import { createSelector } from 'reselect'

const buildCheckTabMessages = () => {
  return createSelector(
    (state, labwareIndex) => StateAccessors.content.tabMessages(state, labwareIndex),
    (messages) => { return (messages.length > 0) }
  )
}

const buildCheckTabErrors = () => {
  return createSelector(
    (state, labwareIndex) => StateAccessors.content.errorTabMessages(state, labwareIndex),
    (messages) => { return (messages.length > 0) }
  )
}

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
    labwareIndexes: createSelector(
      (state) => StateAccessors.manifest.supplierPlateNames(state),
      (names) => names.map((n, pos) => pos)
    ),
    plateIdFor: (state, pos) => StateAccessors.manifest.supplierPlateNames(state)[pos]
  },
  content: {
    buildCheckTabMessages,
    hasTabMessages: buildCheckTabMessages(),
    buildCheckTabErrors,
    hasTabErrors: buildCheckTabErrors(),
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
    get: createSelector(
      (state) => JSON.stringify(state.schema),
      (schema) => JSON.parse(schema)
    ),
    fieldsToShow: createSelector(
      (state) => StateAccessors.schema.get(state),
      (schema) => { return schema.show_on_form || [] }
    ),
    propertyForFieldName: (state, fieldName) => StateAccessors.schema.get(state).properties[fieldName],
    friendlyNameFor: createSelector(
      (state, fieldName) => StateAccessors.schema.propertyForFieldName(state, fieldName),
      (property) => property["friendly_name"]
    ),
    isRequiredField: createSelector(
      (state, fieldName) => StateAccessors.schema.propertyForFieldName(state, fieldName),
      (property) => property["required"]
    ),
    fieldTypeFor: createSelector(
      (state, fieldName) => StateAccessors.schema.propertyForFieldName(state, fieldName),
      (property) => { return property["field_type"] || 'text'}
    ),
    fieldNameForPos: (state, pos) => StateAccessors.schema.fieldsToShow(state)[pos],
    isSelectFieldName: (state, fieldName) => !!StateAccessors.schema.optionsForSelect(state, fieldName),
    optionsForSelect: createSelector(
      (state, fieldName) => StateAccessors.schema.propertyForFieldName(state, fieldName),
      (property) => property['allowed']
    ),
    selectedOptionValue: createSelector(
      [
        (state, fieldName) => StateAccessors.schema.optionsForSelect(state, fieldName),
        (state, fieldName, selectedValue) => selectedValue
      ],
      (options, selectedValue) => {
        return (options.filter((o) => o.match(new RegExp(selectedValue, 'i')))[0] || "")
      }
    )
  }
}

export default StateAccessors
