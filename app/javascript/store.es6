import { createStore } from 'redux'
import reducers from 'reducers/index'

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


const store = createStore(reducers, initialState)

export default store
