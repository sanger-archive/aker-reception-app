import C from '../constants'
import field from './field'

export default (state = {}, action) => {
  switch(action.type) {
    case C.SET_VALUE_TO_FIELD:
      return field(state.contents[action.fieldName], action)
  }
}

