require 'rails_helper'

RSpec.describe Transformers::ExcelToState do

  let(:manifest) { create :manifest }
  let(:user) { create :user }
  let(:transformer) { Transformers::ExcelToState.new(manifest_model: manifest, current_user: user, path: path) }
  let(:path) { 'spec/fixtures/files/good_manifest_with_3_plates.csv' }

  context '#transform' do
    let(:material_schema) {
      { "properties" => {
        "scientific_name" => { "required" => true }, "concentration" => { "required" => false}
      } }
    }

    before do
      mock_taxonomy_client
      allow(MatconClient::Material).to receive(:schema).and_return(material_schema)
    end
    context 'when file is parsed' do
      context 'when the manifest has only 1 labware' do
        before do
          manifest.update_attributes(labwares: 1.times.map { create :labware })
        end
        context 'the schema is not going to declare plate id as required' do
          context 'therefore it will try to put all the contents in the same position on same plate' do
            it 'fails transforming to state' do
              expect(transformer.transform).to be_falsy
            end
            it 'gives an error' do
              expect(transformer.errors).to be_truthy
            end
          end
        end
      end
      context 'when the manifest is declared for 2 labwares' do
        before do
          manifest.update_attributes(labwares: 2.times.map { create :labware })
        end
        context 'the schema will declare plate id as required' do
          context 'but the number of labwares is different between state and manifest' do
            it 'gives an error' do
              expect(transformer.errors).to be_truthy
            end
            it 'fails transforming to state' do
              expect(transformer.transform).to be_falsy
            end
          end
        end
      end

      context 'when the manifest is declared for 3 labwares' do
        before do
          manifest.update_attributes(labwares: 3.times.map { create :labware })
        end
        context 'the schema will declare plate id as required' do
          it 'will perform a right conversion to state' do
            expect(transformer.transform).to be_truthy
            expect(transformer.contents[:content][:structured][:labwares].keys.count).to eq(3)
          end
        end
      end
    end
  end
end
