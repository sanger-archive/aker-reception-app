require 'rails_helper'

RSpec.describe 'Manifest::ProvenanceState::ContentAccessor' do

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
        },
        "plate_id"=>{
          "show_on_form"=>true,"friendly_name"=>"Plate Id","required"=>false,
          "field_name_regex"=>"^plate","type"=>"string"
        },
        "position"=>{
          "show_on_form"=>true,"friendly_name"=>"Position","required"=>false,
          "field_name_regex"=>"position","type"=>"string"
        }
      }
    }
  }

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

  let(:no_of_labwares_required) { 1 }

  let(:manifest) {
    manifest = create :manifest
    manifest.update_attributes(no_of_labwares_required: no_of_labwares_required)
    manifest
  }
  context '#apply error checks' do
    context 'with a manifest with a labware that contains the same position twice' do
      let(:manifest_content) {
        [
            {"plate_id" => "Labware 1", "position" => "A:1", "supplier_name" => "InGen"},
            {"plate_id" => "Labware 1", "position" => "A:1", "supplier_name" => "InGen2"}
        ]
      }

      let(:mapping) {
        {
          valid: true,
          expected: [],
          observed: [], matched: [
            { expected: 'supplier_plate_name', observed: 'plate_id'},
            { expected: 'supplier_name', observed: 'supplier_name'},
            { expected: 'position', observed: 'position'}
          ]
        }
      }

      before do
        allow(content_accessor).to receive(:manifest_schema_field_required?).with("position").and_return(true)
        allow(content_accessor).to receive(:manifest_schema_field_required?).with("supplier_plate_name").and_return(true)
      end

      it 'raises PositionDuplicated' do
        expect{
          content_accessor.apply({mapping: mapping, content: {rebuild: true, raw: manifest_content}})
        }.to raise_error(Manifest::ProvenanceState::ContentAccessor::PositionDuplicated)
      end
    end

    context 'when the labware is not defined in some entries of the manifest' do
      let(:no_of_labwares_required) { 2 }
      let(:manifest_content) {
        [
          {"plate_id" => "Labware 1", "supplier_name" => "InGen", "position" => "A:1"},
          {"supplier_name" => "InGen2", "position" => "A:1"}
        ]
      }

      context 'with a manifest that contains a plate_id match' do
        let(:mapping) {
          {
            valid: true,
            expected: [],
            observed: [], matched: [
              { expected: 'supplier_plate_name', observed: 'plate_id'},
              { expected: 'supplier_name', observed: 'supplier_name'},
              { expected: 'position', observed: 'position'}
            ]
          }
        }

        context 'when the plate_id is required' do

          before do
            allow(content_accessor).to receive(:manifest_schema_field_required?).with("position").and_return(true)
            allow(content_accessor).to receive(:manifest_schema_field_required?).with("supplier_plate_name").and_return(true)
          end

          it 'raises LabwareNotFound error' do
            expect{
              content_accessor.apply({mapping: mapping, content: {rebuild: true, raw: manifest_content}})
            }.to raise_error(Manifest::ProvenanceState::ContentAccessor::LabwareNotFound)
          end
        end

      end
    end

    context 'when the position is not defined in some entries of the manifest' do
      let(:manifest_content) {
        [
          {"plate_id" => "Labware 1", "supplier_name" => "InGen", "position" => "A:1"},
          {"plate_id" => "Labware 1", "supplier_name" => "InGen2"}
        ]
      }

      context 'with a manifest that contains a position match' do
        let(:mapping) {
          {
            valid: true,
            expected: [],
            observed: [], matched: [
              { expected: 'supplier_plate_name', observed: 'plate_id'},
              { expected: 'supplier_name', observed: 'supplier_name'},
              { expected: 'position', observed: 'position'}
            ]
          }
        }

        context 'when the position is required' do

          before do
            allow(content_accessor).to receive(:manifest_schema_field_required?).with("position").and_return(true)
            allow(content_accessor).to receive(:manifest_schema_field_required?).with("supplier_plate_name").and_return(true)
          end

          it 'raises PositionNotFound error' do
            expect{
              content_accessor.apply({mapping: mapping, content: {rebuild: true, raw: manifest_content}})
            }.to raise_error(Manifest::ProvenanceState::ContentAccessor::PositionNotFound)
          end
        end

      end
    end
  end

  context '#validate' do
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

    context 'when the number of labwares in the manifest is less than the number of labwares provided' do
      before do
        allow(MatconClient::Material).to receive(:schema).and_return(schema)
        manifest.update_attributes(labwares: 2.times.map { create :labware })
      end
      it 'not raise an error' do
        expect{content_accessor.apply(content: content)}.not_to raise_error
      end
    end
    context 'when the number of labwares in the manifest is greater than the number of labwares provided' do
      before do
        allow(MatconClient::Material).to receive(:schema).and_return(schema)
        manifest.update_attributes(labwares: 3.times.map { create :labware })
      end
      it 'raises an error' do
        expect{content_accessor.apply(content: content)}.to raise_error(Manifest::ProvenanceState::ContentAccessor::WrongNumberLabwares)
      end
    end
    context 'when the number of labwares in the manifest is equal to the number of labwares provided' do
      before do
        allow(MatconClient::Material).to receive(:schema).and_return(schema)
        manifest.update_attributes(labwares: 1.times.map { create :labware })
      end
      it 'raises an error' do
        expect{content_accessor.apply(content: content)}.to raise_error(Manifest::ProvenanceState::ContentAccessor::WrongNumberLabwares)
      end
    end
  end

  context '#apply' do
    context 'when building structured content from scratch' do
      let (:raw_manifest) { 'a manifest in raw' }
      let (:database_content) { 'some database data' }
      let (:raw_content) { 'some data from raw and mapping' }
      let (:invalid_mapping) { { valid: false } }
      let (:valid_mapping) { { valid: true } }
      before do
        allow(content_accessor).to receive(:validate).and_return(true)
        allow(content_accessor).to receive(:read_from_database).and_return(database_content)
        allow(content_accessor).to receive(:read_from_raw).and_return(raw_content)
      end

      context 'when receiving some structured content' do
        it 'ignores the received structured content' do
          content_accessor.apply({content: {rebuild: true, structured: 'some stuff'}})
          expect(content_accessor.state[:content]).to include(structured: database_content)
        end
      end
      context 'when we do not have raw manifest content in the state' do
        it 'obtains the structured content from the database' do
          content_accessor.apply({content: {rebuild: true}})
          expect(content_accessor.state[:content]).to include(structured: database_content)
        end
      end
      context 'when we do have some raw content' do
        context 'when we do not have a mapping' do
          it 'obtains the structured content from the database' do
            content_accessor.apply({content: {rebuild: true, raw: raw_manifest }})
            expect(content_accessor.state[:content]).to include(structured: database_content)
          end
        end
        context 'when we do not have a valid mapping' do
          it 'obtains the structured content from the database' do
            content_accessor.apply({content: {rebuild: true, raw: raw_manifest }, mapping: invalid_mapping })
            expect(content_accessor.state[:content]).to include(structured: database_content)
          end
        end
        context 'when we have a valid mapping' do
          it 'ignores the database and generates the structured content using both mapping and raw' do
            content_accessor.apply({content: {rebuild: true, raw: raw_manifest }, mapping: valid_mapping })
            expect(content_accessor.state[:content]).to include(structured: raw_content)
          end
        end
      end
    end
    context 'when applying a mapping to generate structured content' do
      before do
        allow(content_accessor).to receive(:manifest_schema_field_required?).with("supplier_plate_name").and_return(false)
        allow(content_accessor).to receive(:manifest_schema_field_required?).with("position").and_return(false)
        content_accessor.apply({schema: schema, mapping: mapping, content: {rebuild: true, raw: manifest_content}})
      end
      context 'with an empty manifest' do
        let(:mapping) {
          {
            valid: true,
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
            valid: true,
            expected: [],
            observed: [], matched: [
              { expected: 'position', observed: 'position'},
              { expected: 'supplier_name', observed: 'supplier_name' }
            ]
          }
        }
        let(:manifest_content) {
          [
            {"supplier_plate_name" => "Labware 1", "position" => "A:1", "supplier_name" => "InGen"},
            {"supplier_plate_name" => "Labware 1", "position" => "B:1", "supplier_name" => "InGen"}
          ]
        }


        it 'does generate content setting plate id for the plate as DEFAULT_LABWARE_NAME_VALUE' do
          expect(content_accessor.state[:content]).to include(structured: { labwares: {
            0 => {
              position: 0,
              supplier_plate_name: "#{default_labware_name_value}",
              addresses: {
            "A:1"=>  { fields: {"position" => {value: "A:1"}, "supplier_name" => {value: "InGen"}}},
            "B:1"=>  { fields: {"position" => {value: "B:1"}, "supplier_name" => {value: "InGen"}}}
            } } } } )
        end

      end
      context 'with a manifest that does not contain position match' do
        let(:mapping) {
          {
            valid: true,
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
        context 'when the position is not required' do
          it 'does generate content setting position for the plate' do
            expect(content_accessor.state[:content]).to include(structured: { labwares: {
              0 => {
                :position=>0, :supplier_plate_name=>"default",
                addresses: {
              "#{default_position_value}"=>  { fields: {"plate_id" => {value: "Labware 1"}, "supplier_name" => {value: "InGen"}}}
              } } } } )
          end
        end
      end


      context 'with a manifest that does not contain either plate_id or position match' do
        let(:mapping) {
          {
            valid: true,
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
            0 => {
              :position=>0, :supplier_plate_name=>"default",
              addresses: {
            "#{default_position_value}"=>  { fields: {"supplier_name" => {value: "InGen"}}}
            } } } } )
        end
      end


      context 'with a matching of plate id using a different attribute than plate_id' do
        let(:mapping) {
          {
            valid: true,
            expected: [],
            observed: [], matched: [
              { expected: 'supplier_plate_name', observed: 'supplier_name'},
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
            0 => {
              :position=>0, :supplier_plate_name=>"InGen",
              addresses: {
            "A:1"=>  { fields: {"position"=>{value: "A:1"}, "supplier_plate_name" => {value: "InGen"}, "supplier_name" => {value: "Labware 1"}}},
            "B:1"=>  { fields: {"position"=>{value: "B:1"}, "supplier_plate_name" => {value: "InGen"}, "supplier_name" => {value: "Labware 2"}}}
            } } } } )
        end
      end


      context 'with a manifest that contains all the fields' do
        let(:mapping) {
          {
            valid: true,
            expected: [],
            observed: [], matched: [
              { expected: 'position', observed: 'position'},{expected: 'supplier_plate_name', observed: 'plate_id'},
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
            0 => {
              :position=>0, :supplier_plate_name=>"Labware 1",
              addresses: {
            "A:1"=>  { fields: {
              "position" => {value: "A:1"}, "supplier_plate_name" => {value: "Labware 1"},
              "is_tumour" => {value: "tum"}, "scientific_name" => {value: "sci"},
            "taxon_id" => {value: "123"}, "supplier_name" => {value: "sup"}, "gender" => {value: "male"}}}
            } } } } )
        end
      end
      context 'with a manifest that contains some fields' do
        let(:mapping) {
          {
            valid: true,
            expected: ["taxon_id", "supplier_name", "gender"],
            observed: ["unknown_value"],
            matched: [
              { expected: 'position', observed: 'position'},{expected: 'supplier_plate_name', observed: 'plate_id'},
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
            labwares: { 0 => {
              :position=>0, :supplier_plate_name=>"Labware 1",
              addresses: {
            "A:1"=>  { fields: {
              "position" => {value: "A:1"}, "supplier_plate_name" => { value: "Labware 1"},
              "is_tumour" => {value: ""}, "scientific_name" => {value: ""}}}
            } } } } )
        end
      end
    end
  end
end
