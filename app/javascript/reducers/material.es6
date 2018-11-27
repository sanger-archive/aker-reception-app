import C from '../constants'
import field from './field'

export default (state = {}, action) => {
  switch(action.type) {
    case C.SET_MANIFEST_VALUE:
      return field(state[action.fieldName], action)
  }
}

