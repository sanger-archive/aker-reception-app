import C from '../constants'
import { combineReducers } from 'redux'
import content from './content'
import mapping from './mapping'
import schema from './schema'
import manifest from './manifest'
import services from './services'

const reducers = combineReducers({
  content,
  mapping,
  schema,
  manifest,
  services
})

export default (state, action) => {
  switch (action.type) {
    case C.LOAD_MANIFEST:
      let obj = Object.assign({}, action.manifest, reducers(state, action))
      return obj
    default:
      return reducers(state, action)
  }
}
