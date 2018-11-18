require 'rails_helper'

RSpec.describe 'Manifest::ProvenanceState::Content' do
  let(:default_position_value) {
    Rails.configuration.manifest_schema_config['default_position_value']
  }
  let(:default_labware_name_value) {
    Rails.configuration.manifest_schema_config['default_labware_name_value']
  }

  let(:labware_name) {
    Rails.configuration.manifest_schema_config["field_labware_name"]

  }
  let(:position) {
    Rails.configuration.manifest_schema_config["field_position"]
  }
  let(:user) { create :user }
  let(:provenance_state) { Manifest::ProvenanceState.new(manifest, user) }
  let(:content_accessor) { provenance_state.content }


  let(:manifest) { create :manifest }
  before do
    content_accessor.apply({mapping: mapping, content: {raw: manifest_content}})
  end
  context '#apply' do
    context 'with an empty manifest' do
      let(:mapping) {
        {
          expected: ["is_tumour", "scientific_name", "taxon_id", "supplier_name", "gender"],
          observed: [], matched: []
        }
      }
      let(:manifest_content) { [] }
      it 'does not generate any content' do
        expect(content_accessor.state[:content]).to include(raw: [], structured: {})
      end
    end
    context 'with a manifest that does not contain plate id match' do
      let(:mapping) {
        {
          expected: [],
          observed: [], matched: [
            { expected: 'position', observed: 'position'},
            { expected: 'supplier_name', observed: 'supplier_name' }
          ]
        }
      }
      let(:manifest_content) {
        [
          "plate_id" => "Labware 1", "position" => "A:1", "supplier_name" => "InGen"
        ]
      }

      it 'does generate content setting plate id for the plate as DEFAULT_LABWARE_NAME_VALUE' do
        expect(content_accessor.state[:content]).to include(structured: { labwares: {
          "#{default_labware_name_value}" => { addresses: {
          "A:1"=>  { fields: {"position" => {value: "A:1"}, "supplier_name" => {value: "InGen"}}}
          } } } } )
      end

    end
    context 'with a manifest that does not contain position match' do
      let(:mapping) {
        {
          expected: [],
          observed: [], matched: [
            { expected: 'plate_id', observed: 'plate_id'},
            { expected: 'supplier_name', observed: 'supplier_name'}
          ]
        }
      }
      let(:manifest_content) {
        [
          "plate_id" => "Labware 1", "position" => "A:1", "supplier_name" => "InGen"
        ]
      }

      it 'does generate content setting position for the plate as DEFAULT_POSITION_VALUE' do
        expect(content_accessor.state[:content]).to include(structured: { labwares: {
          "Labware 1" => { addresses: {
          "#{default_position_value}"=>  { fields: {"plate_id" => {value: "Labware 1"}, "supplier_name" => {value: "InGen"}}}
          } } } } )
      end
    end

    context 'with a manifest with a labware that contains the same position twice' do
      let(:mapping) {
        {
          expected: [],
          observed: [], matched: [
            { expected: 'plate_id', observed: 'plate_id'},
            { expected: 'supplier_name', observed: 'supplier_name'},
            { expected: 'position', observed: 'position'}
          ]
        }
      }
      let(:manifest_content) { [] }

      it 'raises PositionError' do
        content =
          [
            {"plate_id" => "Labware 1", "position" => "A:1", "supplier_name" => "InGen"},
            {"plate_id" => "Labware 1", "position" => "A:1", "supplier_name" => "InGen2"}
          ]

        expect{
          content_accessor.apply({mapping: mapping, content: {raw: content}})
        }.to raise_error(Manifest::ProvenanceState::Content::PositionError)
      end
    end


    context 'with a manifest that does not contain either plate_id or position match' do
      let(:mapping) {
        {
          expected: [],
          observed: [], matched: [
            { expected: 'supplier_name', observed: 'supplier_name'}
          ]
        }
      }
      let(:manifest_content) {
        [
          "plate_id" => "Labware 1", "position" => "A:1", "supplier_name" => "InGen"
        ]
      }

      it 'does generate content setting position and plate_id as default' do
        expect(content_accessor.state[:content]).to include(structured: { labwares: {
          "#{default_labware_name_value}" => { addresses: {
          "#{default_position_value}"=>  { fields: {"supplier_name" => {value: "InGen"}}}
          } } } } )
      end
    end


    context 'with a matching of plate id using a different attribute than plate_id' do
      let(:mapping) {
        {
          expected: [],
          observed: [], matched: [
            { expected: 'plate_id', observed: 'supplier_name'},
            { expected: 'position', observed: 'position'},
            { expected: 'supplier_name', observed: 'plate_id'}
          ]
        }
      }
      let(:manifest_content) {
        [
          {"plate_id" => "Labware 1", "position" => "A:1", "supplier_name" => "InGen"},
          {"plate_id" => "Labware 2", "position" => "B:1", "supplier_name" => "InGen"}
        ]
      }

      it 'does recognise the right plate id attribute to perform the translation' do
        expect(content_accessor.state[:content]).to include(structured: { labwares: {
          "InGen" => { addresses: {
          "A:1"=>  { fields: {"position"=>{value: "A:1"}, "plate_id" => {value: "InGen"}, "supplier_name" => {value: "Labware 1"}}},
          "B:1"=>  { fields: {"position"=>{value: "B:1"}, "plate_id" => {value: "InGen"}, "supplier_name" => {value: "Labware 2"}}}
          } } } } )
      end
    end


    context 'with a manifest that contains all the fields' do
      let(:mapping) {
        {
          expected: [],
          observed: [], matched: [
            { expected: 'position', observed: 'position'},{expected: 'plate_id', observed: 'plate_id'},
            { expected: 'is_tumour', observed: 'is_tumour' }, { expected: 'scientific_name', observed: 'scientific_name' },
            { expected: 'taxon_id', observed: 'taxon_id' }, { expected: 'supplier_name', observed: 'supplier_name' },
            { expected: 'gender', observed: 'gender' }
          ]
        }
      }
      let(:manifest_content) {
        [
          "plate_id" => "Labware 1", "position" => "A:1", "is_tumour" => "tum", "scientific_name" => "sci",
          "taxon_id" => "123", "supplier_name" => "sup", "gender" => "male"
        ]
      }
      it 'does generate the content' do
        expect(content_accessor.state[:content]).to include(structured: { labwares: {
          "Labware 1" => { addresses: {
          "A:1"=>  { fields: {
            "position" => {value: "A:1"}, "plate_id" => {value: "Labware 1"},
            "is_tumour" => {value: "tum"}, "scientific_name" => {value: "sci"},
          "taxon_id" => {value: "123"}, "supplier_name" => {value: "sup"}, "gender" => {value: "male"}}}
          } } } } )
      end
    end
    context 'with a manifest that contains some fields' do
      let(:mapping) {
        {
          expected: ["taxon_id", "supplier_name", "gender"],
          observed: ["unknown_value"],
          matched: [
            { expected: 'position', observed: 'position'},{expected: 'plate_id', observed: 'plate_id'},
            { expected: 'is_tumour', observed: 'is_tumour' },
            { expected: 'scientific_name', observed: 'scientific_name' }
          ]
        }
      }
      let(:manifest_content) {
        [
          "plate_id" => "Labware 1", "position" => "A:1", "is_tumour" => "", "scientific_name" => "", "unknown_value" => ""
        ]
      }
      it 'returns only the list of matched fields' do
        expect(content_accessor.state[:content]).to include(structured: {
          labwares: { "Labware 1" => { addresses: {
          "A:1"=>  { fields: {
            "position" => {value: "A:1"}, "plate_id" => { value: "Labware 1"},
            "is_tumour" => {value: ""}, "scientific_name" => {value: ""}}}
          } } } } )
      end
    end
  end
end
