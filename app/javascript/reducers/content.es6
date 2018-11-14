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
    case C.SET_VALUE_TO_FIELD:
      return tab(state.contents[action.labwareId], action)
    default:
      return state
  }
}
