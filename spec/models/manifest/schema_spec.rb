require 'rails_helper'

RSpec.describe 'Manifest::Schema' do
  let(:manifest) { create :manifest }
  let(:material_schema) {
    { "properties" => { "name" => { "required" => false } } }
  }
  let(:labware_name) {
    Rails.configuration.manifest_schema_config["field_labware_name"]

  }
  let(:position) {
    Rails.configuration.manifest_schema_config["field_position"]
  }

  before do
    allow(MatconClient::Material).to receive(:schema).and_return(material_schema)

  end
  context '#material_schema' do
    it 'returns the material schema object' do
      expect(manifest.material_schema).to eq(material_schema)
    end
  end
  context '#manifest_schema' do
    it 'does not return the same object as the material schema' do
      expect(manifest.manifest_schema).not_to eq(material_schema)
    end
    it 'contains all the additions specified in the manifest_schema.yml config file' do
      expect(manifest.manifest_schema["properties"][labware_name]).not_to eq(nil)
      expect(manifest.manifest_schema["properties"][position]).not_to eq(nil)
    end

    context 'when the manifest model refers to several labware' do
      before do
        manifest.update_attributes(labwares: 2.times.map { create :labware })
      end
      it 'sets the labware name as required' do
        expect(manifest.manifest_schema["properties"][labware_name]["required"]).to be_truthy
      end
    end
    context 'when the manifest model refers to just one labware' do
      before do
        manifest.update_attributes(labwares: 1.times.map { create :labware })
      end
      it 'sets the labware name as not required' do
        expect(manifest.manifest_schema["properties"][labware_name]["required"]).to be_falsy
      end
    end
    context 'when the manifest model refers has several positions' do
      let(:manifest) { create :manifest, labware_type: lt }
      let(:lt) { create :plate_labware_type }
      let(:labwares) { 2.times.map { create :labware } }
      before do
        manifest.update_attributes(labwares: labwares)
      end
      it 'sets the position as required' do
        expect(manifest.manifest_schema["properties"][position]["required"]).to be_truthy
      end
    end
    context 'when the manifest model refers has just one position' do
      let(:manifest) { create :manifest, labware_type: lt }
      let(:lt) { create :tube_labware_type }
      let(:labwares) { 2.times.map { create :labware } }
      before do
        manifest.update_attributes(labwares: labwares)
      end
      it 'sets the position as not required' do
        expect(manifest.manifest_schema["properties"][position]["required"]).to be_falsy
      end
    end
  end
end
