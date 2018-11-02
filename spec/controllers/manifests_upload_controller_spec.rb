require 'rails_helper'

RSpec.shared_examples "successful conversion to csv" do

  it 'is successful' do
    expect(response).to be_successful
  end

  it 'has a Content-Type of application/json' do
    expect(response.content_type).to eql('application/json')
  end

  it 'has contents set' do
    json = JSON.parse(response.body, symbolize_names: true)
    expect(json[:contents]).to_not be_nil
  end

end

RSpec.shared_examples "a valid ManifestEditor state generator" do

  it 'generates the manifest part of the state' do
    json = JSON.parse(response.body, symbolize_names: true)
    expect(!!json[:contents][:manifest]).to eq(true)
  end
  it 'generates the mapping tool part of the state' do
    json = JSON.parse(response.body, symbolize_names: true)
    expect(json[:contents][:mapping_tool]).to include({
      :expected=>[],
      :matched=>[
        {:observed=>"taxon_id", :expected=>"taxon_id"},
        {:observed=>"supplier_name", :expected=>"supplier_name"},
        {:observed=>"gender", :expected=>"gender"}
      ]})
  end
end

RSpec.describe Manifests::UploadController, type: :controller  do
  let(:schema) {
    {
      "show_on_form" => ["taxon_id","supplier_name","gender"],
      "type"=>"object",
      "properties"=>{
        "taxon_id"=>{
          "show_on_form"=>true,"friendly_name"=>"Taxon ID",
          "field_name_regex"=>"^taxon(?:[-_ ]*id)?$","type"=>"string"
        },
        "supplier_name"=>{
          "show_on_form"=>true,"friendly_name"=>"Supplier Name",
          "field_name_regex"=>"^supplier[-_ ]*name$","type"=>"string"
        },
        "gender"=>{
          "show_on_form"=>true,"friendly_name"=>"Gender",
          "field_name_regex"=>"^(?:gender|sex)$","type"=>"string"
        }
      }
    }
  }

  describe 'POST #create' do
    before do
      allow(MatconClient::Material).to receive(:schema).and_return(schema)
      login
      post :create, params: { manifest: file }, xhr: true
    end

    context 'when file is .xlsm' do
      let(:file) { fixture_file_upload('spec/fixtures/files/simple_manifest.xlsm') }
      include_examples "successful conversion to csv"
      it_behaves_like "a valid ManifestEditor state generator"
    end

    context 'when file is an .xlsx' do
      let(:file) { fixture_file_upload('spec/fixtures/files/simple_manifest.xlsx') }
      include_examples "successful conversion to csv"
      it_behaves_like "a valid ManifestEditor state generator"
    end

    context 'when file is an .csv' do
      let(:file) { fixture_file_upload('spec/fixtures/files/simple_manifest.csv') }
      include_examples "successful conversion to csv"
      it_behaves_like "a valid ManifestEditor state generator"
    end

    context 'when file not an .xlsm, .xlsx, or .csv' do

      let(:file) { fixture_file_upload('spec/fixtures/files/WorkOrderJobSets.png') }

      it 'is not successful' do
        expect(response).to_not be_successful
      end

      it 'has a status of 422' do
        expect(response.status).to eql(422)
      end

      it 'has a Content-Type of application/json' do
        expect(response.content_type).to eql('application/json')
      end

      it 'has errors set' do
        json = JSON.parse(response.body, symbolize_names: true)
        expect(json[:errors]).to_not be_nil
      end

    end

  end

end
