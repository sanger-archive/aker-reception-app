import C from '../constants'
import { combineReducers } from 'redux'
import content from 'reducers/content'
import mapping from 'reducers/mapping'
import schema from 'reducers/schema'
import manifest from 'reducers/manifest'
import services from 'reducers/services'

import { isThereAnyRequiredUnmatchedField } from '../helpers'


const isValidMapping = (state) => {
  return !isThereAnyRequiredUnmatchedField(state)
}

const reducers = combineReducers({
  content,
  mapping,
  schema,
  manifest,
  services
})

export default (state, action) => {
  switch(action.type) {
    case C.LOAD_MANIFEST:
      let obj = Object.assign({}, action.manifest, reducers(state, action))
      return obj
    default:
      return reducers(state, action)
  }
}

