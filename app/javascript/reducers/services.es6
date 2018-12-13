import C from '../constants'

export default (state = {}, action) => {

  switch(action.type) {
    case C.LOAD_MANIFEST:
      return Object.assign({}, state, action.manifest.services)
    default:
      return state
  }
}

