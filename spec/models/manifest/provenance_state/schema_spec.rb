require 'rails_helper'

RSpec.describe 'Manifest::ProvenanceState::Schema' do
  let(:manifest) { create :manifest }
  let(:material_schema) {
    { "properties" => { "scientific_name" => { "required" => true }, "concentration" => { "required" => false} } }
  }
  let(:labware_name) {
    Rails.configuration.manifest_schema_config["field_labware_name"]

  }
  let(:position) {
    Rails.configuration.manifest_schema_config["field_position"]
  }
  let(:user) { create :user }
  let(:provenance_state) { Manifest::ProvenanceState.new(manifest, user) }
  let(:schema_accessor) { provenance_state.schema }

  let(:state) {
    {}
  }
  before do
    allow(MatconClient::Material).to receive(:schema).and_return(material_schema)
    schema_accessor.apply(state)
  end
  context '#material_schema' do
    it 'returns the material schema object' do
      expect(schema_accessor.material_schema).to eq(material_schema)
    end
  end
  context '#manifest_schema' do
    it 'does not return the same object as the material schema' do
      expect(schema_accessor.state[:schema]).not_to eq(material_schema)
    end

    context 'when generating the manifest schema using the material schema' do
      context 'with the list of properties defined as property_updates' do
        context 'when the properties are not present in the material schema' do
          it 'adds them to the manifest schema' do
            expect(schema_accessor.material_schema["properties"][labware_name]).to eq(nil)
            expect(schema_accessor.material_schema["properties"][position]).to eq(nil)

            expect(schema_accessor.state[:schema]["properties"][labware_name]).not_to eq(nil)
            expect(schema_accessor.state[:schema]["properties"][position]).not_to eq(nil)
          end
        end
        context 'when the properties are defined both in the material and manifest schemas' do
          it 'rewrites the property values from material with the values defined in the manifest schema' do
            expect(schema_accessor.material_schema["properties"]["scientific_name"]["required"]).to eq(true)
            expect(schema_accessor.state[:schema]["properties"]["scientific_name"]["required"]).to eq(false)
          end
        end
        context 'when material schema has properties no defined in the manifest schema' do
          it 'copies these properties from the material schema into the manifest schema' do
            expect(schema_accessor.state[:schema]["properties"]["concentration"]).not_to eq(nil)
          end
        end
      end
    end

    context 'when completing the generation of the manifest schema' do
      context 'taking decisions about the contents of the manifest' do
        context 'when the manifest refers to several labware' do
          before do
            schema_accessor.apply({manifest: {labwares: [{}, {}]}})
          end
          it 'sets the labware name as required' do
            expect(schema_accessor.state[:schema]["properties"][labware_name]["required"]).to be_truthy
          end
        end
        context 'when the manifest model refers to just one labware' do
          before do
            schema_accessor.apply({manifest: {labwares: [{}]}})
          end
          it 'sets the labware name as not required' do
            expect(schema_accessor.state[:schema]["properties"][labware_name]["required"]).to be_falsy
          end
        end
        context 'when the manifest model refers has several positions' do
          before do
            schema_accessor.apply({manifest: {labwares: [{positions: ["1", "2"]}, {positions: ["1", "2"]}]}})
          end
          it 'sets the position as required' do
            expect(schema_accessor.state[:schema]["properties"][position]["required"]).to be_truthy
          end
        end
        context 'when the manifest model refers has just one position' do
          before do
            schema_accessor.apply({manifest: {labwares: [{positions: ["1"]}, {positions: ["1"]}]}})
          end
          it 'sets the position as not required' do
            expect(schema_accessor.state[:schema]["properties"][position]["required"]).to be_falsy
          end
        end
      end
    end
  end
end
