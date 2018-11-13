import C from '../constants'
import field from './field'

export default (state = {}, action) => {
  switch(action.type) {
    case C.UPLOADED_MANIFEST:
      return Object.assign({}, state, action.manifestData.schema)
    default:
      return state
  }
}

