import C from '../constants'
import tab from './tab'

export default (state = {}, action) => {
  switch(action.type) {
    case C.SET_VALUE_TO_FIELD:
      return tab(state.contents[action.labwareId], action)
  }
}
