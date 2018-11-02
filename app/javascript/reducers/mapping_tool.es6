import C from '../constants'
import field from './field'

export default (state = {}, action) => {
  switch(action.type) {
    case C.MATCH_FIELDS:
      return field(state.contents[action.fieldName], action)
  }
}

