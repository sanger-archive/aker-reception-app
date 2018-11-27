import sinon from 'sinon';
import { expect } from 'chai'
import { StateAccessors } from '../../../app/javascript/lib/state_accessors'

describe('StateAccessor', () => {
  describe('.manifest', () => {
    let state = {
      "manifest": {
        "labwares": [
          {"supplier_plate_name": "Labware 1","positions": ["A:1","B:1"]},
          {"supplier_plate_name": "Labware 2","positions": ["1"]}
        ]
      }
    }
    context('#labwareAtIndex', ()=> {
      it('returns the record at position specified', () => {
        expect(StateAccessors(state).manifest.labwareAtIndex(0).supplier_plate_name).to.equal("Labware 1")
      })
    })
    context('#labwaresForManifest', ()=>{
      it('returns the list of labwares', () => {
        expect(StateAccessors(state).manifest.labwaresForManifest().length).to.equal(2)
      })
    })
  })

  describe('.content', () => {
    let state={
      "content": {
        "structured": {
          "messages": [{
            "type": "warning",
            "display": "alert",
            "text": "There is an error in taxon id 1234"
          }],
          "labwares": {
            "Labware 2": {
              "addresses": {
                "1": {
                  "fields": {}
                }
              }
            },
            "Labware 1": {
              "messages": [{
                "type": "warning",
                "display": "alert",
                "text": "This labware is wrong"
              }],
              "changed": true,
              "invalid": false,
              "addresses": {
                "A:1": {
                  "row": 0,
                  "changed": true,
                  "invalid": false,
                  "fields": {
                    "taxId": {
                      "changed": true,
                      "invalid": true,
                      "value": "1234",
                      "messages": [{"type": "warning", "display": "tooltip", "text": "taxon id is wrong"}]
                    }
                  }
                },
                "B:1": {
                  "row": 0,
                  "changed": true,
                  "invalid": false,
                  "fields": {
                    "taxId": {
                      "changed": true,
                      "invalid": true,
                      "value": "4567",
                    }
                  }
                }
              }
            }
          }
        }
      }
    }

    context('#selectedValueAtCell', ()=> {
      it('returns the value of the cell if it exists', () => {
        expect(StateAccessors(state).content.selectedValueAtCell("Labware 1", "A:1", "taxId")).to.equal("1234")
      })
      it('returns the empty string if it does not exist', () => {
        expect(StateAccessors(state).content.selectedValueAtCell("Labware 1", "A:1", "blabla")).to.equal("")
        expect(StateAccessors(state).content.selectedValueAtCell("Labware 1", "X:1", "taxId")).to.equal("")
        expect(StateAccessors(state).content.selectedValueAtCell("Something", "A:1", "taxId")).to.equal("")
      })
    })

    context('#setValueAtCell', ()=> {
      it('overwrites the new value if it does exist', () => {
        expect(state.content.structured.labwares["Labware 1"].addresses["A:1"].fields["taxId"].value).to.equal("1234")
        StateAccessors(state).content.setValueAtCell("Labware 1", "A:1", "taxId", "asdf")
        expect(state.content.structured.labwares["Labware 1"].addresses["A:1"].fields["taxId"].value).to.equal("asdf")
      })
      it('creates a new entry for a value if it does not exist', () => {
        expect(state.content.structured.labwares["Not existing"]).to.be.undefined
        StateAccessors(state).content.setValueAtCell("Not existing", "A:1", "taxId", "a new value")
        expect(state.content.structured.labwares["Not existing"].addresses["A:1"].fields["taxId"].value).to.equal("a new value")
      })

    })
  })
})
