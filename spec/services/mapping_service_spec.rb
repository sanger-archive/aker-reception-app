require 'rails_helper'

RSpec.describe :mapping_service do
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

  let(:manifest) { create :manifest }
  let(:user) { create :user }
  let(:mapping_service) { MappingService.new(manifest, user) }
  before do
    allow(manifest).to receive(:manifest_schema).and_return(schema)
  end

  context '#process_state' do
    let(:state) { create :manifest_editor_valid_state }
  end
  context '#process_array' do
    context 'generating the mapping info' do
      context 'with an empty manifest' do
        let(:manifest_content) { {} }
        it 'does not match anything' do
          expect(mapping_service.process_array(manifest_content)[:manifest][:mapping]).to include(
            expected: ["is_tumour", "scientific_name", "taxon_id", "supplier_name", "gender"],
            observed: [], matched: []
          )
        end
        it 'does not validate the mapping' do
          expect(mapping_service.process_array(manifest_content)[:manifest][:mapping][:valid]).to be_falsy
        end
      end
      context 'with a manifest that contains all the fields' do
        let(:manifest_content) {
          [
            "is_tumour" => "", "scientific_name" => "", "taxon_id" => "", "supplier_name" => "", "gender" => ""
          ]
        }
        it 'does match everything' do
          expect(mapping_service.process_array(manifest_content)[:manifest][:mapping]).to include(
            expected: [],
            observed: [], matched: [
              { expected: 'is_tumour', observed: 'is_tumour' }, { expected: 'scientific_name', observed: 'scientific_name' },
              { expected: 'taxon_id', observed: 'taxon_id' }, { expected: 'supplier_name', observed: 'supplier_name' },
              { expected: 'gender', observed: 'gender' }
            ]
          )
        end
        it 'validates the mapping' do
          expect(mapping_service.process_array(manifest_content)[:manifest][:mapping][:valid]).to be_truthy
        end
      end
      context 'with a manifest that contains some fields' do
        let(:manifest_content) {
          [
            "is_tumour" => "", "scientific_name" => "", "unknown_value" => ""
          ]
        }
        it 'returns the list of matched pairs and the list of columsn unmatched in both sides' do
          expect(mapping_service.process_array(manifest_content)[:manifest][:mapping]).to include(
            expected: ["taxon_id", "supplier_name", "gender"],
            observed: ["unknown_value"],
            matched: [
              { expected: 'is_tumour', observed: 'is_tumour' }, { expected: 'scientific_name', observed: 'scientific_name' }
            ]
          )
        end
      end
      context 'when there are columns in the schema without a regular expression' do
        let(:schema) {
          {"properties" => {
            "column_to_show" => { "show_on_form" => true, "field_name_regex" => "column_to_show"},
            "column_to_hide" => { "show_on_form" => true}
          }}
        }
        let(:manifest_content) {
          [
            "column_to_show" => "", "column_to_hide" => ""
          ]
        }
        it 'does not expect to find them, but matches the others' do
          expect(mapping_service.process_array(manifest_content)[:manifest][:mapping]).to include(
            expected: [],
            observed: ["column_to_hide"],
            matched: [
              { expected: 'column_to_show', observed: 'column_to_show' }
            ]
          )
        end
      end
      context 'when there are columns in the schema that must not be shown in the form' do
        let(:schema) {
          {"properties" => {
            "column_to_show" => { "show_on_form" => true, "field_name_regex" => "column_to_show"},
            "column_to_hide" => { "show_on_form" => false, "field_name_regex" => "column_to_hide"}
          }}
        }
        let(:manifest_content) {
          [
            "column_to_show" => "", "column_to_hide" => ""
          ]
        }

        it 'does not expect to find them, but matches the others' do
          expect(mapping_service.process_array(manifest_content)[:manifest][:mapping]).to include(
            expected: [],
            observed: ["column_to_hide"],
            matched: [
              { expected: 'column_to_show', observed: 'column_to_show' }
            ]
          )
        end

        context 'when any of this columns not to shown are actually required by the schema' do
          let(:schema) {
            {"properties" => {
              "column_to_show" => { "show_on_form" => true, "field_name_regex" => "column_to_show"},
              "hidden_required_column" => { "show_on_form" => false, "field_name_regex" => "hidden_required_column",
                "required" => true}
            }}
          }

          it 'expects to find them and tries to map them' do
            expect(mapping_service.process_array(manifest_content)[:manifest][:mapping]).to include(
              expected: ["hidden_required_column"],
              observed: ["column_to_hide"],
              matched: [
                { expected: 'column_to_show', observed: 'column_to_show' }
              ]
            )
          end
        end
      end
    end
  end
end
