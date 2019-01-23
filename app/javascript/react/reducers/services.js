import C from '../constants'

export default (state = {}, action) => {
  switch (action.type) {
    case C.LOAD_MANIFEST:
      return Object.assign({}, state, action.manifest.services)
    case C.CACHE_TAXONOMY:
      return Object.assign({}, state, {
        cachedTaxonomies: Object.assign(state.cachedTaxonomies || {}, action.data)
      })
    default:
      return state
  }
}
