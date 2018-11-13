import C from '../constants'
import { combineReducers } from 'redux'
import content from 'reducers/content'
import mapping from 'reducers/mapping'
import schema from 'reducers/schema'

import { isThereAnyRequiredUnmatchedField } from '../helpers'


const isValidMapping = (state) => {
  return !isThereAnyRequiredUnmatchedField(state)
}

const reducers = combineReducers({
  content,
  mapping,
  schema
})

export default (state = {}, action) => {
  state = reducers(state, action)
  const validMapping = isValidMapping(state)

  switch(action.type) {
    case C.MATCH_SELECTION:
    case C.UNMATCH:
      return Object.assign({}, state, {
        mapping: Object.assign({}, state.mapping, {
          valid: validMapping
        })
      })
    case C.UPLOADED_MANIFEST:
      return Object.assign({}, state, {
        mapping: Object.assign({}, state.mapping, {
          valid: validMapping,
          shown: !validMapping
        })
      })
    default:
      return state
  }
}

