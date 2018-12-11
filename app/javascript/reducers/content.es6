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
  createKeys(state,
    [
      'structured', 'labwares', labwareId, 'addresses', address,
      'fields', fieldName
    ]).value = value
}

export const removeEmptyRows = (newState, labwareId, address) => {
  let fields = newState.structured.labwares[labwareId].addresses[address].fields

  /* If the other inputs do not have any value, remove the address from the state */
  let fieldsWithValue = Object.keys(fields).filter((k) => {
    if ((k=='plate_id') || (k=='position')) {
      return false
    }
    return (fields[k].value && (fields[k].value.length > 0))
  })
  if (fieldsWithValue.length == 0) {
    delete newState.structured.labwares[labwareId].addresses[address]
    return newState
  }
}


export default (state = {}, action) => {

  let newState
  switch(action.type) {
    case C.DISPLAY_MESSAGE:
      let displayObj = Object.assign({}, state)
      if (!displayObj.structured) {
        displayObj.structured={}
      }
      Object.assign(displayObj.structured, {messages: [action.data]})
      return displayObj
    case C.SET_MANIFEST_VALUE:
      newState = Object.assign({}, state)
      console.log('STATE=')
      console.log(state)

      setManifestValue(newState, action.labwareId, action.address, "plate_id", action.labwareId)
      setManifestValue(newState, action.labwareId, action.address, "position", action.address)
      setManifestValue(newState, action.labwareId, action.address, action.fieldName, action.value)
      removeEmptyRows(newState, action.labwareId, action.address)
      console.log('NEWSTATE=')
      console.log(newState)
      return newState
    default:
      return state
  }
}
