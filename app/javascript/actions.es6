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

export const setManifestValue = (labwareId, address, fieldName, value) => {
  return {
    type: C.SET_MANIFEST_VALUE, labwareId, address, fieldName, value
  }
}

export const saveTab = (labwareId) => {
  return {
    type: C.SAVE_TAB, labwareId
  }
}

export const restoreTab = (labwareId) => {
  return {
    type: C.RESTORE_TAB, labwareId
  }
}
