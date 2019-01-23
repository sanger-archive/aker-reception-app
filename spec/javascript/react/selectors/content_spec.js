import sinon from 'sinon';
import { expect } from 'chai'
import ContentSelector from "../../../../app/javascript/react/selectors/content"

describe('ContentSelector', () => {

  const warningMessage = {
    "labware_index": 0,
    "level": "WARN",
    "address": "A:1",
    "field": "taxonId",
    "display": "alert",
    "text": "There is an error in taxon id 1234"
  }
  const errorMessage = {
    "labware_index": 1,
    "level": "ERROR",
    "address": "33",
    "field": "name",
    "display": "alert",
    "text": "There is some other problem"
  }

  let state={
    "content": {
      "structured": {
        "messages": [warningMessage, errorMessage],
        "labwares": {
          "0": {
            "addresses": {
              "A:1": {
                "fields": {
                  "taxonId": {
                    "value": "1234"
                  }
                }
              },
              "B:1": {
                "fields": {
                  "taxonId": {
                    "value": "4567"
                  }
                }
              }
            }
          }
        }
      }
    }
  }

  context("#tabMessages", () => {
    it('returns the list of messages for the selected tab', () => {
      expect(ContentSelector.tabMessages(state, 0)).to.eql([warningMessage])
      expect(ContentSelector.tabMessages(state, 1)).to.eql([errorMessage])
    })
  })

  context("#hasTabMessages", () => {
    it('tells if the selected tab has messages', () => {
      expect(ContentSelector.hasTabMessages(state, 0)).to.eql(true)
      expect(ContentSelector.hasTabMessages(state, 1)).to.eql(true)
    })
  })

  context("#hasTabErrors", () => {
    it('tells if the selected tab has errors', () => {
      expect(ContentSelector.hasTabErrors(state, 0)).to.eql(false)
      expect(ContentSelector.hasTabErrors(state, 1)).to.eql(true)
    })
  })

  context("#warningTabMessages", () => {
    it('returns the list of warning messages for the selected tab', () => {
      expect(ContentSelector.warningTabMessages(state, 0)).to.eql([warningMessage])
      expect(ContentSelector.warningTabMessages(state, 1)).to.eql([])
    })
  })

  context("#errorTabMessages", () => {
    it('returns the list of error messages for the selected tab', () => {
      expect(ContentSelector.errorTabMessages(state, 0)).to.eql([])
      expect(ContentSelector.errorTabMessages(state, 1)).to.eql([errorMessage])
    })
  })

  context("#inputMessages", () => {
    it('returns the messages for the specified input', () => {
      expect(ContentSelector.inputMessages(state, {labwareIndex: 0, address: 'A:1', fieldName: 'taxonId'})).to.eql([warningMessage])
      expect(ContentSelector.inputMessages(state, {labwareIndex: 1, address: '33', fieldName: 'name'})).to.eql([errorMessage])
    })
  })

  context("#errorInputMessages", () => {
    it('returns the messages for the specified input', () => {
      expect(ContentSelector.errorInputMessages(state, {labwareIndex: 0, address: 'A:1', fieldName: 'taxonId'})).to.eql([])
      expect(ContentSelector.errorInputMessages(state, {labwareIndex: 1, address: '33', fieldName: 'name'})).to.eql([errorMessage])
    })
  })

  context("#warningInputMessages", () => {
    it('returns the messages for the specified input', () => {
      expect(ContentSelector.warningInputMessages(state, {labwareIndex: 0, address: 'A:1', fieldName: 'taxonId'})).to.eql([warningMessage])
      expect(ContentSelector.warningInputMessages(state, {labwareIndex: 1, address: '33', fieldName: 'name'})).to.eql([])
    })
  })

  context("#hasInputMessages", () => {
    it('returns the messages for the specified input', () => {
      expect(ContentSelector.hasInputMessages(state, {labwareIndex: 0, address: 'A:1', fieldName: 'taxonId'})).to.eql(true)
      expect(ContentSelector.hasInputMessages(state, {labwareIndex: 1, address: '33', fieldName: 'name'})).to.eql(true)
    })
  })

  context("#hasInputErrors", () => {
    it('returns the messages for the specified input', () => {
      expect(ContentSelector.hasInputErrors(state, {labwareIndex: 0, address: 'A:1', fieldName: 'taxonId'})).to.eql(false)
      expect(ContentSelector.hasInputErrors(state, {labwareIndex: 1, address: '33', fieldName: 'name'})).to.eql(true)
    })
  })

  context('#selectedValueAtCell', ()=> {
    it('returns the value of the cell if it exists', () => {
      expect(ContentSelector.selectedValueAtCell(state, "0", "A:1", "taxonId")).to.equal("1234")
    })
    it('returns the empty string if it does not exist', () => {
      expect(ContentSelector.selectedValueAtCell(state,"0", "A:1", "blabla")).to.equal("")
      expect(ContentSelector.selectedValueAtCell(state,"0", "X:1", "taxonId")).to.equal("")
      expect(ContentSelector.selectedValueAtCell(state,"3", "A:1", "taxonId")).to.equal("")
    })
  })
})
