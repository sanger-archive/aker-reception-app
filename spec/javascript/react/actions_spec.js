import sinon from 'sinon'
import { expect } from 'chai'
import C from "../../../app/javascript/react/constants"
import {updateScientificName} from "../../../app/javascript/react/actions"


import configureMockStore from "redux-mock-store"
import thunk from "redux-thunk"
import nock from "nock"


const TAXONOMY_SERVICE_URL = "http://mockingservice"
const TAXONOMIES = {
  "9606": {
    "taxId": "9606",
    "scientificName": "Homo sapiens"
  }
}
const HUMAN_TAXON_ID = "9606"

nock(TAXONOMY_SERVICE_URL)
  .defaultReplyHeaders({ 'access-control-allow-origin': '*' })
  .get('/' + HUMAN_TAXON_ID)
  .reply(200, TAXONOMIES[HUMAN_TAXON_ID])


export const mockStore = configureMockStore([thunk])

describe("Actions", () => {
  let state={
    "services": {
      "taxonomyNumCalls": 1,
      "taxonomyServiceUrl": TAXONOMY_SERVICE_URL
    }
  }


  context('#updateScientificName', () => {
    it("caches any new taxonomy received and sets the manifest value", async () => {
      const store = mockStore(state)

      // Now we have to subscribe to modify manually the store, because this mock does not support running reducers...
      store.subscribe(() => { state.services.taxonomyNumCalls = 2 })

      await store.dispatch(updateScientificName("1", "A:1", "scientificName", HUMAN_TAXON_ID, "Labware 1", TAXONOMY_SERVICE_URL))
      const actions = store.getActions()
      expect(actions[0]).eql({type: "SET_TAXONOMY_NUM_CALLS", value: 2})
      expect(actions[1]).eql({type: "CACHE_TAXONOMY", data: TAXONOMIES })
      expect(actions[2]).eql({
        type: "SET_MANIFEST_VALUE",
        address: "A:1",
        fieldName: "scientificName",
        labwareId: "1",
        plateId: "Labware 1",
        type: "SET_MANIFEST_VALUE",
        value: "Homo sapiens"
      })
    })
  })
})
