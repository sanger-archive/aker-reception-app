import sinon from 'sinon';
import { expect } from 'chai'
import SchemaSelector from "../../../../app/javascript/react/selectors/schema"

describe('SchemaSelector', () => {
  let state = {
    schema: {
      show_on_form: ['taxId', 'sampleName', 'tissue', 'groupId'],
      properties: {
        taxId: { friendly_name: "Taxon id", required: true},
        scientificName: { friendlyName: "Scientific Name", required: true, editable: false},
        sampleName: { friendly_name: "Sample Name"},
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
  context('#isEditableField', () => {
    it('defaults to true if the editable property is not set', () => {
      expect(SchemaSelector.isEditableField(state, 'taxId')).to.equal(true)
    })
    it('defaults to the value of the editable property if set', () => {
      expect(SchemaSelector.isEditableField(state, 'scientificName')).to.equal(false)
    })
  })
  context('#isRequiredField', () => {
    it('defaults to false if the editable property is not set', () => {
      expect(SchemaSelector.isRequiredField(state, 'sampleName')).to.equal(false)
    })
    it('defaults to the value of the editable property if set', () => {
      expect(SchemaSelector.isRequiredField(state, 'scientificName')).to.equal(true)
      expect(SchemaSelector.isRequiredField(state, 'tissue')).to.equal(false)
    })
  })

  context('#isSelectFieldName', () => {
    it('indicates if a field can be represented as a select', () => {
      expect(SchemaSelector.isSelectFieldName(state, 'groupId')).to.equal(true)
      expect(SchemaSelector.isSelectFieldName(state, 'sampleName')).to.equal(false)
    })
  })
  context('#optionsForSelect', () => {
    it('returns the allowed values for a field', () => {
      expect(SchemaSelector.optionsForSelect(state, 'groupId')).to.eql(["C1", "C2","AsDeF"])
    })
  })

})
