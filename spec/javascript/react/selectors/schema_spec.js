import sinon from 'sinon';
import { expect } from 'chai'
import SchemaSelector from "../../../../app/javascript/react/selectors/schema"

describe('SchemaSelector', () => {
  let state = {
    schema: {
      show_on_form: ['taxId', 'sampleName', 'tissue', 'groupId'],
      properties: {
        taxId: { friendly_name: "Taxon id", required: true},
        sampleName: { friendly_name: "Sample Name", required: true},
        tissue: { friendly_name: "Tissue", required: false},
        groupId: {friendly_name: "GroupId", required: false, allowed: ["C1", "C2","AsDeF"]}
      }
    }
  }

  context('#get', () => {
    it('returns the schema', () =>{
      expect(SchemaSelector.get(state)).to.eql(state.schema)
    })
  })
  context('#selectedOptionValue', () => {
    it('matches the valid option when case do not match', () => {
      expect(SchemaSelector.selectedOptionValue(state, 'groupId','asdef')).to.equal("AsDeF")
    })
    it('returns the empty string if trying to find an empty string', () => {
      expect(SchemaSelector.selectedOptionValue(state, 'groupId','')).to.equal("")
    })
    it('returns the empty string if trying to find null', () => {
      expect(SchemaSelector.selectedOptionValue(state, 'groupId',null)).to.equal("")
    })
    it('returns the empty string if no match is found', () => {
      expect(SchemaSelector.selectedOptionValue(state, 'groupId','ardf')).to.equal("")
    })
  })
})
