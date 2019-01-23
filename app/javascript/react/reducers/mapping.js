import C from '../constants'

export default (state = {}, action) => {
  switch (action.type) {
    case C.LOAD_MANIFEST:
      return Object.assign({}, state, action.manifest.mapping)

    case C.MATCH_SELECTION:
      let mp = Object.assign({}, state)
      mp.matched.push({ observed: action.observed, expected: action.expected })
      mp.observed = mp.observed.filter((elem) => { return elem !== action.observed })
      mp.expected = mp.expected.filter((elem) => { return elem !== action.expected })

      return Object.assign({ rebuild: true }, state, mp, { selectedObserved: null, selectedExpected: null })
    case C.UNMATCH:
      let mapping = Object.assign({}, state)
      mapping.matched = mapping.matched.filter((elem) => {
        return !((elem.observed === action.observed) && (elem.expected === action.expected))
      })
      mapping.observed.push(action.observed)
      mapping.expected.push(action.expected)
      return Object.assign({ rebuild: true }, state, mapping)
    case C.SELECT_OBSERVED_OPTION:
      return Object.assign({}, state, { selectedObserved: action.value })
    case C.SELECT_EXPECTED_OPTION:
      return Object.assign({}, state, { selectedExpected: action.value })
    case C.TOGGLE_MAPPING:
      return Object.assign({ rebuild: true }, state, { shown: action.toggle })
    default:
      return state
  }
}
