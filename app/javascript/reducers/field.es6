import C from '../constants'

export default (state = {}, action) => {
  switch(action.type) {
    case C.SET_MANIFEST_VALUE:
      debugger
      return Object.assign({}, state).merge({value: action.value})
    default:
      return state
  }
}

