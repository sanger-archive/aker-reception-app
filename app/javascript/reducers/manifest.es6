import C from '../constants'

export default (state = {}, action) => {

  switch(action.type) {
    case C.CHANGE_TAB:
      return Object.assign({}, state, { selectedTabPosition: action.position })
    default:
      return state
  }
}

