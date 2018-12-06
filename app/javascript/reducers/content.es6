import C from '../constants'
import { StateAccessors } from '../selectors'

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
      let obj = ['structured', 'labwares',
        action.labwareId, 'addresses',
        action.address, 'fields',
        action.fieldName
      ].reduce((memo, key) => {
        if (!memo[key]) {
          memo[key] = {}
        }
        return memo[key]
      }, newState)

      /* Set the value */
      obj.value = action.value

      let fields = newState.structured.labwares[action.labwareId].addresses[action.address].fields

      /* If the other inputs do not have any value, remove the address from the state */
      let fieldsWithValue = Object.keys(fields).filter((k) => {
        if ((k=='plate_id') || (k=='position')) {
          return false
        }
        return (fields[k].value && (fields[k].value.length > 0))
      })
      if (fieldsWithValue.length == 0) {
        delete newState.structured.labwares[action.labwareId].addresses[action.address]
        return newState
      }

      /** Add plate id and position if they do not have */
      if (!fields.plate_id || (!fields.plate_id.value)) {
        if (!fields.plate_id) {
          fields.plate_id = {}
        }
        fields.plate_id.value = action.plateId
      }
      if (!fields.position || (!fields.position.value)) {
        if (!fields.position) {
          fields.position = {}
        }
        fields.position.value = action.address
      }
      return newState
    default:
      return state
  }
}
