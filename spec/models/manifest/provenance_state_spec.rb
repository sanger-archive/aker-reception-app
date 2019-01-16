require 'rails_helper'

RSpec.describe 'Manifest::ProvenanceState' do
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
  context '#apply' do
    context 'with an empty state' do
      let(:tube_type) {
        create(:labware_type,
                            num_of_cols: 1,
                            num_of_rows: 1,
                            row_is_alpha: false,
                            col_is_alpha: false)
      }

      before do
        manifest.update_attributes(labware_type: tube_type)
        manifest.update_attributes(labwares: 3.times.map{ create :labware })
        allow(MatconClient::Material).to receive(:schema).and_return(material_schema)
      end

      it 'generates a right state' do
        expect(provenance_state.apply({})[:manifest]).to include({
          :manifest_id=>manifest.id, :labwares=>[
            {:labware_index=>"1", :positions=>["1"], :supplier_plate_name => "Labware 1"},
            {:labware_index=>"2", :positions=>["1"], :supplier_plate_name => "Labware 2"},
            {:labware_index=>"3", :positions=>["1"], :supplier_plate_name => "Labware 3"}]
          })
      end
    end

    context 'with a normal state' do
      let(:state) {
        {
          mapping: mapping,
          content: content,
          schema: schema
        }
      }

      let(:schema) {
        {
          "show_on_form"=> ["taxon_id","scientific_name","supplier_name","gender","is_tumour"],
          "type"=>"object",
          "properties"=>{
            "is_tumour"=>{
              "show_on_form"=>true,"friendly_name"=>"Tumour?","required"=>false,
              "field_name_regex"=>"^(?:is[-_ ]+)?tumou?r\\??$","type"=>"string"
            },
            "scientific_name"=>{
              "show_on_form"=>true,"friendly_name"=>"Scientific Name","required"=>false,
              "field_name_regex"=>"^scientific(?:[-_ ]*name)?$","type"=>"string"
            },
            "taxon_id"=>{
              "show_on_form"=>true,"friendly_name"=>"Taxon ID","required"=>false,
              "field_name_regex"=>"^taxon(?:[-_ ]*id)?$","type"=>"string"
            },
            "supplier_name"=>{
              "show_on_form"=>true,"friendly_name"=>"Supplier Name","required"=>true,
              "field_name_regex"=>"^supplier[-_ ]*name$","type"=>"string"
            },
            "gender"=>{
              "show_on_form"=>true,"friendly_name"=>"Gender","required"=>false,
              "field_name_regex"=>"^(?:gender|sex)$","type"=>"string"
            }
          }
        }

      }
      let(:content) {
        {
          raw: [
              {"plate_id" => "Labware 1", "position" => "A:1", "is_tumour" => "", "scientific_name" => "", "taxon_id" => "", "supplier_name" => "", "gender" => ""}
          ],
          structured: { labwares: { "Labware 1" => { addresses: { "A:1"=>  { fields:
            {"is_tumour" => {value: ""}, "scientific_name" => {value: ""}, "taxon_id" => {value: ""}, "supplier_name" => {value: ""}, "gender" => {value: ""}}
        } } } } } }
      }
      let(:mapping) {
        {
          expected: [],
          observed: [], matched: [
            { expected: 'is_tumour', observed: 'is_tumour' }, { expected: 'scientific_name', observed: 'scientific_name' },
            { expected: 'taxon_id', observed: 'taxon_id' }, { expected: 'supplier_name', observed: 'supplier_name' },
            { expected: 'gender', observed: 'gender' }
          ]
        }
      }
      before do
        allow(MatconClient::Material).to receive(:schema).and_return(material_schema)
        manifest.update_attributes(labwares: 1.times.map { create :labware })
      end

      it 'defines manifest_id' do
        provenance_state.apply(state)
        expect(provenance_state.state[:manifest][:manifest_id]).to eq(manifest.id)
      end

      context 'when the state does not have updates' do
        before do
          allow(MatconClient::Material).to receive(:schema).and_return(material_schema)

          provenance_state.apply(state)
        end


        it 'returns back the same state' do
          expect(provenance_state.state).to include(state)
        end
      end
      context 'when file defines more labwares than the manifest created' do
        before do
          allow(MatconClient::Material).to receive(:schema).and_return(material_schema)
          manifest.update_attributes(labwares: 1.times.map { create :labware })

        end

        let(:content) {
          {
            raw: [
                {"plate_id" => "Labware 1", "position" => "A:1", "is_tumour" => "", "scientific_name" => "", "taxon_id" => "", "supplier_name" => "", "gender" => ""},
                {"plate_id" => "Labware 2", "position" => "A:1", "is_tumour" => "", "scientific_name" => "", "taxon_id" => "", "supplier_name" => "", "gender" => ""}
            ],
            structured: { labwares: {
              "Labware 1" => { addresses: { "A:1"=>  { fields:
              {"is_tumour" => {value: ""}, "scientific_name" => {value: ""}, "taxon_id" => {value: ""},
              "supplier_name" => {value: ""}, "gender" => {value: ""}}}}},
              "Labware 2" => { addresses: { "A:1"=>  { fields:
              {"is_tumour" => {value: ""}, "scientific_name" => {value: ""}, "taxon_id" => {value: ""},
              "supplier_name" => {value: ""}, "gender" => {value: ""}}}}}

          } } }
        }
        it 'raises an error' do
          expect{provenance_state.apply(state)}.to raise_error(Manifest::ProvenanceState::ContentAccessor::WrongNumberLabwares)
        end

      end

      context 'when file defines less labwares than the manifest created' do
        before do
          allow(MatconClient::Material).to receive(:schema).and_return(material_schema)
          manifest.update_attributes(labwares: 3.times.map { create :labware })

        end

        let(:content) {
          {
            raw: [
                {"plate_id" => "Labware 1", "position" => "A:1", "is_tumour" => "", "scientific_name" => "", "taxon_id" => "", "supplier_name" => "", "gender" => ""},
                {"plate_id" => "Labware 2", "position" => "A:1", "is_tumour" => "", "scientific_name" => "", "taxon_id" => "", "supplier_name" => "", "gender" => ""}
            ],
            structured: { labwares: {
              "Labware 1" => { addresses: { "A:1"=>  { fields:
              {"is_tumour" => {value: ""}, "scientific_name" => {value: ""}, "taxon_id" => {value: ""},
              "supplier_name" => {value: ""}, "gender" => {value: ""}}}}},
              "Labware 2" => { addresses: { "A:1"=>  { fields:
              {"is_tumour" => {value: ""}, "scientific_name" => {value: ""}, "taxon_id" => {value: ""},
              "supplier_name" => {value: ""}, "gender" => {value: ""}}}}}

          } } }
        }
        it 'raises an error' do
          expect{provenance_state.apply(state)}.to raise_error(Manifest::ProvenanceState::ContentAccessor::WrongNumberLabwares)
        end

      end
    end
  end
end
