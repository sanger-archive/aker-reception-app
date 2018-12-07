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

const userTiming = () => (next) => (action) => {
  if (performance.mark === undefined) return next(action);
  performance.mark(`${action.type}_start`);
  const result = next(action);
  performance.mark(`${action.type}_end`);
  performance.measure(
    `${action.type}`,
    `${action.type}_start`,
    `${action.type}_end`,
  );
  return result;
}


const store = createStore(reducers, initialState, applyMiddleware(thunk, userTiming))

//sagaMiddleware.run(saga)

export default store
