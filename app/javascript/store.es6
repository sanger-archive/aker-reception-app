import { createStore, applyMiddleware } from 'redux'
import reducers from 'reducers/index'
import createSagaMiddleware from 'redux-saga'
import saga from 'sagas/index'

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

const sagaMiddleware = createSagaMiddleware()

const store = createStore(reducers, initialState, applyMiddleware(sagaMiddleware))

sagaMiddleware.run(saga)

export default store
