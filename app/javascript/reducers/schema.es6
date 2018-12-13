import C from '../constants'

export default (state = {}, action) => {

  switch(action.type) {
    case C.LOAD_MANIFEST:
      return Object.assign({}, state, action.manifest.schema)

    case C.UPLOADED_MANIFEST:
      return Object.assign({}, state, action.manifestData.schema)
    default:
      return state
  }
}

