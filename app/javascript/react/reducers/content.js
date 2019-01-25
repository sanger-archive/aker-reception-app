import C from '../constants'

export const createKeys = (state, keys) => {
  return keys.reduce((memo, key) => {
    if (!memo[key]) {
      memo[key] = {}
    }
    return memo[key]
  }, state)
}

export const setManifestValue = (state, labwareId, address, fieldName, value) => {
  Object.assign(createKeys(state,
    [
      'structured', 'labwares', labwareId, 'addresses', address,
      'fields', fieldName
    ]), { value })
}

export const removeEmptyRows = (newState, labwareId, address) => {
  let fields = newState.structured.labwares[labwareId].addresses[address].fields

  /* If the other inputs do not have any value, remove the address from the state */
  let fieldsWithValue = Object.keys(fields).filter((k) => {
    if ((k === 'supplier_plate_name') || (k === 'position')) {
      return false
    }
    return (fields[k].value && (fields[k].value.length > 0))
  })
  if (fieldsWithValue.length === 0) {
    delete newState.structured.labwares[labwareId].addresses[address]
    return newState
  }
}

export const found = (state, labwareId, addressId, fieldName, value) => {
  return state?.structured?.labwares?.[labwareId]?.addresses?.[addressId]?.fields?.[fieldName]
}

const applyForAddresses = (state, handler) => {
  const labwares = state?.structured?.labwares
  for (let labwareId in labwares) {
    let labware = labwares[labwareId]
    for (let addressId in labware.addresses) {
      let address = labware.addresses[addressId]
      for (let fieldName in address.fields) {
        handler.call(this, labwareId, addressId, fieldName)
      }
    }
  }
}

const resetPreviousValues = (prevState, newState) => {
  applyForAddresses(prevState, (labwareId, addressId, fieldName) => {
    if (!found(newState, labwareId, addressId, fieldName)) {
      setManifestValue(newState, labwareId, addressId, fieldName, '')
    }
  })
  return newState
}

export default (state = {}, action) => {
  switch (action.type) {
    case C.TOGGLE_MAPPING:
      if (!action.toggle) {
        return Object.assign({}, state, { raw: null })
      }
      return state
    case C.SAVE_AND_LEAVE:
      if (state.update_successful === true) {
        window.location.href = action.url
      }
      return state
    case C.LOAD_MANIFEST:
      return resetPreviousValues(state, Object.assign({}, action.manifest.content))
    case C.DISPLAY_MESSAGE:
      let displayObj = Object.assign({ structured: {} }, state)
      Object.assign(displayObj.structured, { messages: [action.data] })
      return displayObj
    case C.SET_MANIFEST_VALUE:
      let newState = Object.assign({}, state)

      setManifestValue(newState, action.labwareId, action.address, 'supplier_plate_name', action.labwareId)
      setManifestValue(newState, action.labwareId, action.address, 'position', action.address)
      setManifestValue(newState, action.labwareId, action.address, action.fieldName, action.value)
      removeEmptyRows(newState, action.labwareId, action.address)
      return newState
    default:
      return state
  }
}
