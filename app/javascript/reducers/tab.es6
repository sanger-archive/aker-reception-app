import C from '../constants'
import material from './material'

export default (state = {}, action) => {
  switch(action.type) {
    case C.SET_VALUE_TO_FIELD:
      return material(state.contents[action.address], action)
  }
}

