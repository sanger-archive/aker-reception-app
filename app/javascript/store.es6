import { createStore, applyMiddleware } from 'redux'
import reducers from 'reducers/index'
//import createSagaMiddleware from 'redux-saga'
//import saga from 'sagas/index'
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

//const sagaMiddleware = createSagaMiddleware()

const store = createStore(reducers, initialState, applyMiddleware(thunk))

//sagaMiddleware.run(saga)

export default store
