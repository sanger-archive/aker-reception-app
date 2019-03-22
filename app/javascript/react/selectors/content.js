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
    (state, props) => ContentSelector.inputMessages(state, props),
    (messages) => (messages.length > 0)
  )
}

export const buildCheckInputErrors = () => {
  return createSelector(
    (state, props) => ContentSelector.errorInputMessages(state, props),
    (messages) => (messages.length > 0)
  )
}

const sanitizedAddress = (address) => {
  if (!address.includes(":")) {
    const matches = address.match(/([^\d])(\d*)/)
    if ((matches) && (matches[2])) {
      try {
        return (matches[1]+":"+parseInt(matches[2], 10))
      } catch(e) {
        console.log("Matched integer regex out of bounds")
      }
    }
  }
  return address
}

const equalityIndex = (a,b) => {
  return (((a==null) && (b==null)) ||
    ((typeof a !== 'undefined') && (typeof b !== 'undefined') && ((a!==null) && (b!==null)) && (a.toString()===b.toString())))
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

  isWarning: (m) => { return (m.level === 'WARNING') },
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
      return ((m.labware_index === null) || (m.labware_index === undefined) || equalityIndex(m.labware_index, tabIndex))
    }) || [])
  },

  inputMessages: (state, props) => {
    return ContentSelector.tabMessages(state, props.labwareIndex).filter((m) => {
      return (equalityIndex(m.labware_index, props.labwareIndex) &&
        (sanitizedAddress(m.address) === sanitizedAddress(props.address)) && (m.field === props.fieldName))
    })
  },

  errorInputMessages: createSelector(
    (state, props) => ContentSelector.inputMessages(state, props),
    (messages) => messages.filter((m) => !ContentSelector.isWarning(m))
  ),

  warningInputMessages: createSelector(
    (state, props) => ContentSelector.inputMessages(state, props),
    (messages) => messages.filter((m) => ContentSelector.isWarning(m))
  ),

  selectedValueAtCell: (state, labwareId, address, fieldName) => {
    const val = state?.content?.structured?.labwares?.[labwareId]?.addresses?.[sanitizedAddress(address)]?.fields?.[fieldName]?.value
    return (val || '')
  }
}

export default ContentSelector
