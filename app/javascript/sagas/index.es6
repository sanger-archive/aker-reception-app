import C from '../constants'
import { call, put, takeEvery, takeLatest } from 'redux-saga/effects'

// worker Saga: will be fired on USER_FETCH_REQUESTED actions
function* saveTab(action) {
  debugger
  //$.post($(this.form).attr('action'), $(this.form).serialize())
   try {
      const response = yield call($.post, $(this.form).attr('action'), $(this.form).serialize())
      //const user = yield call(Api.fetchUser, action.payload.labwareId);
      yield put({type: C.LOAD_MANIFEST, user: user});
   } catch (e) {
      yield put({type: C.LOAD_MANIFEST, message: e.message});
   }
}

function* restoreTab(action) {
   try {
      const response = yield call($.get, $(this.form).attr('action'))
      //const user = yield call(Api.fetchUser, action.payload.labwareId);
      yield put({type: C.LOAD_MANIFEST, user: user});
   } catch (e) {
      yield put({type: C.LOAD_MANIFEST, message: e.message});
   }
}

/*
  Starts fetchUser on each dispatched `USER_FETCH_REQUESTED` action.
  Allows concurrent fetches of user.
*/
function* mySaga() {
  //yield takeEvery(C.SAVE_TAB, saveTab);
  yield takeLatest(C.SAVE_TAB, saveTab);
  yield takeLatest(C.RESTORE_TAB, saveTab);
}

/*
  Alternatively you may use takeLatest.

  Does not allow concurrent fetches of user. If "USER_FETCH_REQUESTED" gets
  dispatched while a fetch is already pending, that pending fetch is cancelled
  and only the latest one will be run.
*/
/*function* mySaga() {
  yield takeLatest("USER_FETCH_REQUESTED", fetchUser);
}*/

export default mySaga;
