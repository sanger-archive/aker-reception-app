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
    expect(!!json[:contents]).to eq(true)
  end
  it 'generates the mapping tool part of the state' do
    json = JSON.parse(response.body, symbolize_names: true)
    expect(json[:contents][:mapping][:observed]).to eq([])
    expect(json[:contents][:mapping][:expected]).to eq(["scientific_name"])
    expect(json[:contents][:mapping][:matched]).to include(
      {:observed=>"taxon_id", :expected=>"taxon_id"},
      {:observed=>"supplier_name", :expected=>"supplier_name"},
      {:observed=>"gender", :expected=>"gender"}
    )
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
  let(:lt) { create :plate_labware_type }
  let(:manifest) { create :manifest, labware_type: lt }
  let(:labware) { create :labware }

  describe 'POST #create' do
    before do
      @user = OpenStruct.new(email: 'other@sanger.ac.uk', groups: %w[world team252])
      allow(controller).to receive(:check_credentials)
      allow(controller).to receive(:current_user).and_return(@user)

      manifest.update_attributes(labwares: [labware])

      allow(MatconClient::Material).to receive(:schema).and_return(schema)
      login
      post :create, params: { manifest: file, manifest_id: manifest.id }, xhr: true
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
