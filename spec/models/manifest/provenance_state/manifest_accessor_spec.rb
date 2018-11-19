require 'rails_helper'

RSpec.describe 'Manifest::ProvenanceState::ManifestAccessor' do
  let(:manifest) { create :manifest }
  let(:user) { create :user }
  let(:provenance_state) { Manifest::ProvenanceState.new(manifest, user) }
  let(:manifest_accessor) { provenance_state.manifest }
  let(:state) {
    {}
  }
  context '#apply' do
    let(:tube_type) {
      create(:labware_type,
                          num_of_cols: 1,
                          num_of_rows: 1,
                          row_is_alpha: false,
                          col_is_alpha: false)
    }
    let(:plate_type) {
      create(:labware_type,
                          num_of_cols: 2,
                          num_of_rows: 1,
                          row_is_alpha: true,
                          col_is_alpha: false)
    }

    context 'when the manifest does not have any labware defined' do
      it 'does generate an empty labwares list' do
        expect(manifest_accessor.apply(state)).to include({
          manifest: {
            manifest_id: manifest.id,
            labwares: [
            ]
          }
        })
      end
    end

    context 'when the manifest has labware with one position inside' do
      before do
        manifest.update_attributes(labware_type: tube_type)
        manifest.update_attributes(labwares: 2.times.map { create :labware })
      end

      it 'generates labware with one position' do
        expect(manifest_accessor.apply(state)).to include({
          manifest: {
            manifest_id: manifest.id,
            labwares: [
              { labware_index: "1", positions: ["1"]},
              { labware_index: "2", positions: ["1"]}
            ]
          }
        })
      end
    end

    context 'when the manifest has labware with several positions inside' do
      before do
        manifest.update_attributes(labware_type: plate_type)
        manifest.update_attributes(labwares: 2.times.map { create :labware })
      end


      it 'generates labware with several positions' do
        expect(manifest_accessor.apply(state)).to include({
          manifest: {
            manifest_id: manifest.id,
            labwares: [
              { labware_index: "1", positions: ["A:1", "A:2"]},
              { labware_index: "2", positions: ["A:1", "A:2"]}
            ]
          }
        })
      end
    end

    context 'when the manifest has supplier plate names for the labware' do
      before do
        manifest.update_attributes(labware_type: plate_type)
        labwares = 2.times.map do |idx|
          create :labware, supplier_plate_name: "plate #{idx+1}"
        end
        manifest.update_attributes(labwares: labwares)
      end

      it 'generates supplier plate name ' do
        expect(manifest_accessor.apply(state)).to include({
          manifest: {
            manifest_id: manifest.id,
            labwares: [
              { labware_index: "1", supplier_plate_name: "plate 1", positions: ["A:1", "A:2"]},
              { labware_index: "2", supplier_plate_name: "plate 2", positions: ["A:1", "A:2"]}
            ]
          }
        })
      end
    end
  end
end
