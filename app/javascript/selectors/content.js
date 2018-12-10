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

export const ContentSelector = {
  buildCheckTabMessages,
  hasTabMessages: buildCheckTabMessages(),
  buildCheckTabErrors,
  hasTabErrors: buildCheckTabErrors(),
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
    let val = state?.content?.structured?.messages?.filter((m) => m.labware_index==tabIndex)
    return (val ? val : [])
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

  hasInputMessages: createSelector(
    (state, props) => ContentSelector.inputMessages(state,props),
    (messages) => (messages.length > 0)
  ),

  hasInputErrors: createSelector(
    (state, props) => ContentSelector.errorInputMessages(state,props),
    (messages) => (messages.length > 0)
  ),

  selectedValueAtCell: (state, labwareId, address, fieldName) => {
    const val = state?.content?.structured?.labwares?.[labwareId]?.addresses?.[address]?.fields?.[fieldName]?.value
    return (val ? val : "")
  }
}

export default ContentSelector
