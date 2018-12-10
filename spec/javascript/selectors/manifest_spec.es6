import sinon from 'sinon';
import { expect } from 'chai'
import ManifestSelector from "../../../app/javascript/selectors/manifest"

describe('ManifestSelector', () => {
  let state = {
    "manifest": {
      "selectedTabPosition":1,
      "labwares": [
        {"supplier_plate_name": "Labware 1","positions": ["A:1","B:1"]},
        {"supplier_plate_name": "Labware 2","positions": ["1"]}
      ]
    }
  }
  context('#selectedTabPosition', () => {
    it('returns the selected tab as an integer', () => {
      expect(ManifestSelector.selectedTabPosition(state)).to.equal(1)
    })
  })
  context('#positionsForLabware', ()=> {
    it('returns the positions for the selected labware', () => {
      expect(ManifestSelector.positionsForLabware(state, 0)).to.eql(["A:1","B:1"])
    })
  })
  context('#supplierPlateNames', ()=>{
    it('returns the list of supplier plate names', () => {
      expect(ManifestSelector.supplierPlateNames(state)).to.eql(["Labware 1", "Labware 2"])
    })
  })
  context('#labwareIndexes', ()=>{
    it('returns the list of indexes for the plates', () => {
      expect(ManifestSelector.labwareIndexes(state)).to.eql([0, 1])
    })
  })
  context('#plateIdFor', ()=>{
    it('returns the supplier plate name at position', () => {
      expect(ManifestSelector.plateIdFor(state, 1)).to.equal("Labware 2")
    })
  })

})
