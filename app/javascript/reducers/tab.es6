import C from '../constants'
import material from './material'

export default (state = {}, action) => {
  switch(action.type) {
    case C.SET_MANIFEST_VALUE:
      return material(state[action.address], action)
  }
}

