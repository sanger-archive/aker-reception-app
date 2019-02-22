import C from './constants'
import Reception from '../routes.js.erb'
import $ from 'jquery'

export const matchSelection = (expected, observed) => {
  return {
    type: C.MATCH_SELECTION,
    observed,
    expected
  }
}

export const unmatch = (expected, observed) => {
  return {
    type: C.UNMATCH,
    observed,
    expected
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

  if (Object.keys(dupState.mapping).length === 0) {
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


export const setTaxonomyNumCalls = (numCalls) => {
  return {
    type: C.SET_TAXONOMY_NUM_CALLS,
    value: numCalls
  }
}

const updateScientificNameFromService = (dispatch, getState, labwareId, address, fieldName, taxId, plateId, taxonomyServiceUrl) => {
  const taxonomyNumCalls = getState().services.taxonomyNumCalls ? getState().services.taxonomyNumCalls + 1 : 1
  dispatch(setTaxonomyNumCalls(taxonomyNumCalls))
  return $.ajax(taxonomyServiceUrl + '/' + taxId, {
    method: 'GET',
    contentType: 'application/json',
    dataType: 'json'
  }).then((data) => {
    dispatch(cacheTaxonomy(taxId, data))
    if (taxonomyNumCalls === getState().services.taxonomyNumCalls) {
      dispatch(setManifestValue(labwareId, address, fieldName, data.scientificName, plateId))
    }
  }).fail((e) => {
    if (taxonomyNumCalls === getState().services.taxonomyNumCalls) {
      if (e.status === 404) {
        dispatch(setManifestValue(labwareId, address, fieldName, '', plateId))
        dispatch(displayMessage({ level: 'FATAL',
          display: 'alert',
          text: 'There is no scientific name for the taxon id provided',
          labware_index: labwareId, address, field: fieldName }))
      } else {
        dispatch(displayMessage({ level: 'FATAL', display: 'alert', text: 'There was an error while connecting to the EBI taxonomy service' }))
      }
    }
  })
}

export const updateScientificName = (labwareId, address, fieldName, taxId, plateId, taxonomyServiceUrl) => {
  return (dispatch, getState) => {
    if (taxId.length === 0) {
      dispatch(setManifestValue(labwareId, address, fieldName, '', plateId))
      return Promise.resolve()
    }
    const cache = getState().services.cachedTaxonomies
    if (cache && cache[taxId]) {
      dispatch(setManifestValue(labwareId, address, fieldName, cache[taxId].scientificName, plateId))
      return Promise.resolve()
    }

    return updateScientificNameFromService(dispatch, getState, labwareId, address, fieldName, taxId, plateId, taxonomyServiceUrl)
  }
}

const isAbortedRequest = (xhr) => {
  return ((xhr.status === 0) && (xhr.statusText === 'abort'))
}

export const showManifestUploadError = (dispatch, xhr) => {
  if (isAbortedRequest(xhr)) {
    return
  }

  dispatch(displayMessage({
    labwareIndex: null,
    address: null,
    level: 'FATAL',
    display: 'alert',
    text: xhr.responseJSON.errors.join('\n')
  }))
}

export const storeSavingRequest = (savingRequest) => {
  return {
    type: C.STORE_SAVING_REQUEST, savingRequest
  }
}

export const saveTab = (form) => {
  return (dispatch, getState) => {
    const state = getState()
    const manifestId = state.manifest.manifest_id
    const path = Reception.manifests_state_path(manifestId)

    const request = $.ajax(path, {
      method: 'PUT',
      contentType: 'application/json',
      dataType: 'json',
      data: JSON.stringify(getState())
    })
    dispatch(storeSavingRequest(request))

    return request.then((data) => {
      dispatch(loadManifest(data.contents))
      dispatch(storeSavingRequest(null))
    }, $.proxy(showManifestUploadError, this, dispatch))
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
      dispatch({ type: C.SAVE_AND_LEAVE, url })
    })
  }
}

const uploadManifestToService = (dispatch, getState, ajaxRequest, manifest, manifestId) => {
  return $.ajax(ajaxRequest).then($.proxy(function (response, event) {
    const manifest = response.contents
    dispatch(loadManifest(manifest))
    if (!getState().mapping.valid) {
      dispatch(selectExpectedOption(null))
      dispatch(selectObservedOption(null))
      $('#myModal').modal('show')
    }
  }, this), $.proxy(showManifestUploadError, this, dispatch))
    .always(() => {
      $(document).trigger('hideLoadingOverlay')
    })
}

export const uploadManifest = (manifest, manifestId) => {
  return (dispatch, getState) => {
    let formData = new window.FormData()
    formData.append('manifest', manifest)
    formData.append('manifest_id', manifestId)
    $(document).trigger('showLoadingOverlay')

    const ajaxRequest = {
      url: Reception.manifests_upload_index_path(),
      type: 'POST',
      method: 'POST',
      data: formData,
      cache: false,
      contentType: false,
      processData: false
    }

    return uploadManifestToService(dispatch, getState, ajaxRequest, manifest, manifestId)
  }
}
