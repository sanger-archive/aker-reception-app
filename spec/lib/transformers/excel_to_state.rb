require 'rails_helper'

RSpec.describe Transformers::ExcelToState do
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
  let(:transformer) { build(:excel_to_state) }
  before do
    allow(MatconClient::Material).to receive(:schema).and_return(schema)
    allow(transformer).to receive(:manifest).and_return(manifest)
  end
  context '#mapping_tool' do
    context 'with an empty manifest' do
      let(:manifest) { {} }
      it 'does not match anything' do
        expect(transformer.mapping_tool).to eq(
          expected: ["is_tumour", "scientific_name", "taxon_id", "supplier_name", "gender"],
          observed: [], matched: []
        )
      end
    end
    context 'with a manifest that contains all the fields' do
      let(:manifest) {
        [
          "is_tumour" => "", "scientific_name" => "", "taxon_id" => "", "supplier_name" => "", "gender" => ""
        ]
      }
      it 'does match everything' do
        expect(transformer.mapping_tool).to eq(
          expected: [],
          observed: [], matched: [
            { expected: 'is_tumour', observed: 'is_tumour' }, { expected: 'scientific_name', observed: 'scientific_name' },
            { expected: 'taxon_id', observed: 'taxon_id' }, { expected: 'supplier_name', observed: 'supplier_name' },
            { expected: 'gender', observed: 'gender' }
          ]
        )
      end
    end
    context 'with a manifest that contains some fields' do
      let(:manifest) {
        [
          "is_tumour" => "", "scientific_name" => "", "unknown_value" => ""
        ]
      }
      it 'returns the list of matched pairs and the list of columsn unmatched in both sides' do
        expect(transformer.mapping_tool).to eq(
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
      let(:manifest) {
        [
          "column_to_show" => "", "column_to_hide" => ""
        ]
      }
      it 'does not expect to find them, but matches the others' do
        expect(transformer.mapping_tool).to eq(
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
      let(:manifest) {
        [
          "column_to_show" => "", "column_to_hide" => ""
        ]
      }

      it 'does not expect to find them, but matches the others' do
        expect(transformer.mapping_tool).to eq(
          expected: [],
          observed: ["column_to_hide"],
          matched: [
            { expected: 'column_to_show', observed: 'column_to_show' }
          ]
        )
      end
    end
  end
end
