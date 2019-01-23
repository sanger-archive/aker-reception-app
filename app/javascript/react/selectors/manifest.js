import { createSelector } from 'reselect'

export const ManifestSelector = {
  selectedTabPosition: createSelector(
    (state) => state?.manifest?.selectedTabPosition,
    (selectedTab) => { return parseInt(selectedTab, 10) }
  ),
  positionsForLabware: createSelector(
    (state, labwarePos) => state?.manifest?.labwares?.[labwarePos],
    (labware) => labware?.positions
  ),
  supplierPlateNames: createSelector(
    (state) => state?.manifest?.labwares || [],
    (labwares) => labwares.map((l) => l.supplier_plate_name)
  ),
  labwareIndexes: createSelector(
    (state) => ManifestSelector.supplierPlateNames(state),
    (names) => names.map((n, pos) => pos)
  ),
  plateIdFor: (state, pos) => ManifestSelector.supplierPlateNames(state)[pos]
}

export default ManifestSelector
