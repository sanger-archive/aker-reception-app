import C from '../constants'
import tab from './tab'

// Plate ID field
const PLATE_ID_FIELD = {
  required: true,
  field_name_regex: "^plate",
  friendly_name: "Plate ID",
  show_on_form: true
};

// Position field that needs to be added to the schema which comes from the material service
const POSITION_FIELD = {
  required: true,
  field_name_regex: "^(well(\\s*|_*|-*))?position$",
  friendly_name: "Position",
  show_on_form: true
}

export default (state = {}, action) => {

  switch(action.type) {
    case C.MATCH_SELECTION:
      let mp = Object.assign({}, state.mapping)
      mp.matched.push({observed: action.observed, expected: action.expected})
      mp.observed=mp.observed.filter((elem) => {return elem != action.observed})
      mp.expected=mp.expected.filter((elem) => {return elem != action.expected})
      return Object.assign({}, state, {mapping: mp})
    case C.UNMATCH:
      let mapping = Object.assign({}, state.mapping)
      mapping.matched = mapping.matched.filter((elem) => {
        return !((elem.observed == action.observed) && (elem.expected == action.expected))
      })
      mapping.observed.push(action.observed)
      mapping.expected.push(action.expected)
      return Object.assign({}, state, {mapping})

    case C.UPLOADED_MANIFEST:
      action.manifestData.schema.properties.plate_id = PLATE_ID_FIELD
      action.manifestData.schema.properties.position = POSITION_FIELD

      return Object.assign(state, action.manifestData)
      //return Object.assign({}, state.merge(action.manifestData))
    case C.SET_VALUE_TO_FIELD:
      return tab(state.contents[action.labwareId], action)
  }
}
