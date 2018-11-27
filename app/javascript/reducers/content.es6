import C from '../constants'
import { StateAccessors } from '../lib/state_accessors'

export default (state = {}, action) => {
  let newState
  switch(action.type) {
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
      obj.value = action.value
      return newState
    default:
      return state
  }
}
