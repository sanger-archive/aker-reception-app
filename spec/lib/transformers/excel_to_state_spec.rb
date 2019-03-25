require 'rails_helper'

RSpec.describe Transformers::ExcelToState do

  let(:lt) { create :labware_type}
  let(:manifest) { create :manifest, labware_type: lt}
  let(:user) { create :user }
  let(:transformer) { Transformers::ExcelToState.new(manifest_model: manifest, current_user: user, path: path) }
  let(:path) { 'spec/fixtures/files/good_manifest_with_3_plates.csv' }

  context '#transform' do
    let(:material_schema) {
      { "properties" => {
        "scientific_name" => { "required" => true },
        "concentration" => { "required" => false}
      } }
    }

    before do
      mock_taxonomy_client
      allow(MatconClient::Material).to receive(:schema).and_return(material_schema)
      manifest.update_attributes(labwares: 3.times.map { create :labware })
    end
    context 'when file is parsed' do
      context 'when there is some errors on parsing' do
        let(:path) { 'spec/fixtures/files/corrupted_simple_manifest.xlsx' }
        it 'fails transforming to state' do
          expect(transformer.transform).to be_falsy
        end
        it 'gives an error' do
          expect(transformer.errors).to be_truthy
        end
      end

      context 'when there is no errors' do
        it 'will perform a right conversion to state' do
          expect(transformer.transform).to be_truthy
          expect(transformer.contents[:content][:structured][:labwares].keys.count).to eq(3)
        end
      end
    end
  end
end
