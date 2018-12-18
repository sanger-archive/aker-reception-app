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
    //,
    /*meta: {
      debounce: {
        time: 1000,
        key: 'SET_MANIFEST_INPUT_DEBOUNCED'
      }
    }*/
  }
}

export const filteredState = (state) => {
  let dupState = Object.assign({}, state)

  if (Object.keys(dupState.mapping).length == 0) {
    delete dupState.mapping
  }
}

export const cacheTaxonomy = (taxId, data) => {
  let obj = {}
  obj[taxId] = data

  return {
    type: C.CACHE_TAXONOMY,
    data: obj
  }
}

export const updateScientificName = (labwareId, address, fieldName, taxId, plateId, taxonomyServiceUrl) => {
  return (dispatch, getState) => {
    if (taxId.length == 0) {
      dispatch(setManifestValue(labwareId, address, fieldName, "", plateId))
      return
    }
    const cache = getState().services.cachedTaxonomies
    if (cache) {
      const val = cache[taxId]
      if (val) {
        dispatch(setManifestValue(labwareId, address, fieldName, val.scientificName, plateId))
        return
      }
    }
    return $.ajax(taxonomyServiceUrl+'/'+taxId, {
      method: 'GET',
      contentType: 'application/json',
      dataType: 'json'
    }).then((data) => {
      dispatch(cacheTaxonomy(taxId, data))
      dispatch(setManifestValue(labwareId, address, fieldName, data.scientificName, plateId))
    }).fail((e) => {
      if (e.status==404) {
        dispatch(setManifestValue(labwareId, address, fieldName, "", plateId))
        dispatch(displayMessage({level: 'FATAL',
          display: 'alert', text: "There is no scientific name for the taxon id provided" , labware_index: labwareId, address, field: fieldName
        }))
      } else {
        dispatch(displayMessage({level: 'FATAL', display: 'alert', text: "There was an error while connecting to the EBI taxonomy service" }))
      }
    })
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
  return { type: C.TOGGLE_MAPPING, toggle }
}


export const changeTab = (position) => {
  return {
    type: C.CHANGE_TAB, position
  }
}

export const saveAndLeave = (url) => {
  return (dispatch, getState) => {
    dispatch(saveTab()).then(() => {
      dispatch({ type: C.SAVE_AND_LEAVE, url})
    })
  }
}
