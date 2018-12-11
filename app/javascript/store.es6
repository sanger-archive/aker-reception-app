import { createStore, applyMiddleware } from 'redux'
import reducers from 'reducers/index'

import thunk from 'redux-thunk';

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


const store = createStore(reducers, initialState, applyMiddleware(thunk))

export default store
