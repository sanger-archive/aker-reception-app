import C from './constants'

export const matchSelection = (expected, observed) => {
  return {
    type: C.MATCH_SELECTION,
    observed, expected
  }
}

export const unmatch = (expected, observed) =>  {
  return {
    type: C.UNMATCH,
    observed, expected
  }
}

export const loadManifest = (manifest) => {
  return {
    type: C.LOAD_MANIFEST, manifest
  }
}

export const selectExpectedOption = (val) => {
  return {
    type: C.SELECT_EXPECTED_OPTION, value: val
  }
}

export const selectObservedOption = (val) => {
  return {
    type: C.SELECT_OBSERVED_OPTION, value: val
  }
}

export const setManifestValue = (labwareId, address, fieldName, value, plateId) => {
  return {
    type: C.SET_MANIFEST_VALUE, labwareId, address, fieldName, value, plateId
  }
}

export const filteredState = (state) => {
  let dupState = Object.assign({}, state)

  if (Object.keys(dupState.mapping).length == 0) {
    delete dupState.mapping
  }
}

export const saveTab = (form) => {
  return (dispatch, getState) => {
    const state = getState()
    const manifestId = state.manifest.manifest_id

    return $.ajax("/manifests/state/"+manifestId, {
      method: 'PUT',
      contentType: 'application/json',
      dataType: 'json',
      data: JSON.stringify(getState())
    }).then((data) => {
      dispatch(loadManifest(data.contents))
    }).fail((e) => {
      dispatch(displayMessage({level: 'FATAL', display: 'alert', text: "There is no connection with the service" }))
    })
  }
}

export const displayMessage = (data) => {
  return { type: C.DISPLAY_MESSAGE, data }
}

export const toggleMapping = (toggle) => {
  return { type: C.TOGGLE_MAPPING, toggle}
}

export const restoreTab = (labwareId) => {
  return {
    type: C.RESTORE_TAB, labwareId
  }
}

export const changeTab = (position) => {
  return {
    type: C.CHANGE_TAB, position
  }
}
