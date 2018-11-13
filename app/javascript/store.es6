import { createStore } from 'redux'
import manifest from 'reducers/manifest'

const initialState = {
  "content": {
  },
  "mapping": {
    "shown": false,
    "matched": [],
    "expected": [],
    "observed": []
  },
  "schema": null
}


const store = createStore(manifest, initialState)

export default store
