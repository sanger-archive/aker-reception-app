require 'rails_helper'

RSpec.describe Transformers::StateToState do

  let(:manifest) { create :manifest }
  let(:user) { create :user }
  let(:opts) {
    {manifest_model: manifest, current_user: user, state:
    {schema: material_schema, content: {structured: {}}, mapping: {}}}
  }
  let(:transformer) {
    Transformers::StateToState.new(opts)
  }

  context '#transform' do
    let(:material_schema) {
      { "properties" => { "scientific_name" => { "required" => true }, "concentration" => { "required" => false} } }
    }

    before do
      allow(MatconClient::Material).to receive(:schema).and_return(material_schema)
    end
    context 'when file is parsed' do
      it 'generates a valid state' do
        transformer.transform
        expect(opts[:state][:content][:structured].nil?).to eq(false)
      end
    end
  end
end
