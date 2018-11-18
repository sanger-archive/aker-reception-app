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

    context 'when the state does not have updates' do
      before do
        allow(MatconClient::Material).to receive(:schema).and_return(material_schema)
        provenance_state.apply(state)
      end

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

      it 'returns back the same state' do
        expect(provenance_state.state).to include(state)
      end
    end
  end
end
