import { createStore, combineReducers } from 'redux'
import manifest from 'reducers/manifest'
import mappingTool from 'reducers/mapping_tool'

const initialState = {
  "manifest": {
    "type": "Manifest",
    "loading": false,
    "contents": {}
  },
  "mappingTool": {
    "shown": false,
    "fieldsMatched": [],
    "leftFieldsUnmatched": [],
    "rightFieldsUnmatched": []
  }
}

const store = createStore(
    manifest,
    initialState
)

export default store
