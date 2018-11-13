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

export const uploadManifest = (response) => {
  return {
    type: C.UPLOADED_MANIFEST, manifestData: response.contents.manifest
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
