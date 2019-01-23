import sinon from 'sinon';
import { expect } from 'chai'
import C from "../../../../app/javascript/react/constants"
import contentReducer from "../../../../app/javascript/react/reducers/content"


describe('ContentReducer', () => {
  const action = {
    type: C.SET_MANIFEST_VALUE,
    labwareId: "0",
    address: "A:1",
    fieldName: "taxId",
    value: "1234"
  }

  context('with SET_MANIFEST_VALUE', ()=> {
    it('overwrites the new value if it does exist', () => {
      let state = {structured:{labwares:{"0": {addresses: {"A:1": {fields: {"taxId": {"value": "4567"}}}}}}}}
      expect(state.structured.labwares["0"].addresses["A:1"].fields["taxId"].value).to.equal("4567")
      expect(contentReducer(state, action).structured.labwares["0"].addresses["A:1"].fields["taxId"].value).to.equal("1234")
    })
    it('creates a new entry for a value if it does not exist', () => {
      expect(contentReducer({}, action).structured.labwares["0"].addresses["A:1"].fields["taxId"].value).to.equal("1234")
    })
  })
})
