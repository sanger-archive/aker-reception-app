import { createSelector } from 'reselect'

export const buildCheckTabMessages = () => {
  return createSelector(
    (state, labwareIndex) => ContentSelector.tabMessages(state, labwareIndex),
    (messages) => { return (messages.length > 0) }
  )
}

export const buildCheckTabErrors = () => {
  return createSelector(
    (state, labwareIndex) => ContentSelector.errorTabMessages(state, labwareIndex),
    (messages) => { return (messages.length > 0) }
  )
}

export const buildCheckInputMessages = () => {
  return createSelector(
    (state, props) => ContentSelector.inputMessages(state,props),
    (messages) => (messages.length > 0)
  )
}

export const buildCheckInputErrors = () => {
  return createSelector(
    (state, props) => ContentSelector.errorInputMessages(state,props),
    (messages) => (messages.length > 0)
  )
}

export const ContentSelector = {
  buildCheckTabMessages,
  hasTabMessages: buildCheckTabMessages(),

  buildCheckTabErrors,
  hasTabErrors: buildCheckTabErrors(),

  buildCheckInputMessages,
  hasInputMessages: buildCheckInputMessages(),

  buildCheckInputErrors,
  hasInputErrors: buildCheckInputErrors(),

  isWarning: (m) => { return (m.level == 'WARN')},
  warningTabMessages: createSelector(
    (state, labwareIndex) => ContentSelector.tabMessages(state, labwareIndex),
    (messages) => messages.filter((m) => ContentSelector.isWarning(m))
  ),
  errorTabMessages: createSelector(
    (state, labwareIndex) => ContentSelector.tabMessages(state, labwareIndex),
    (messages) => messages.filter((m) => !ContentSelector.isWarning(m))
  ),
  tabMessages: (state, tabIndex) => {
    return (state?.content?.structured?.messages?.filter((m) => {
      return (m.labware_index==tabIndex) || (m.labware_index==null)
    }) || [])
  },

  inputMessages: (state, props) => {
    return ContentSelector.tabMessages(state, props.labwareIndex).filter((m) => {
      return ((m.labware_index == props.labwareIndex) && (m.address == props.address) && (m.field==props.fieldName))
    })
  },

  errorInputMessages: createSelector(
    (state, props) => ContentSelector.inputMessages(state,props),
    (messages) => messages.filter((m) => !ContentSelector.isWarning(m))
  ),

  warningInputMessages: createSelector(
    (state, props) => ContentSelector.inputMessages(state,props),
    (messages) => messages.filter((m) => ContentSelector.isWarning(m))
  ),

  selectedValueAtCell: (state, labwareId, address, fieldName) => {
    const val = state?.content?.structured?.labwares?.[labwareId]?.addresses?.[address]?.fields?.[fieldName]?.value
    return (val ? val : "")
  }
}

export default ContentSelector
