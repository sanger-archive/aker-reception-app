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

RSpec.describe Manifests::UploadController, type: :controller  do

  describe 'POST #create' do

    before do
      login
      post :create, params: { manifest: file }, xhr: true
    end

    context 'when file is .xlsm' do
      let(:file) { fixture_file_upload('spec/fixtures/files/simple_manifest.xlsm') }
      include_examples "successful conversion to csv"
    end

    context 'when file is an .xlsx' do
      let(:file) { fixture_file_upload('spec/fixtures/files/simple_manifest.xlsx') }
      include_examples "successful conversion to csv"
    end

    context 'when file is an .csv' do
      let(:file) { fixture_file_upload('spec/fixtures/files/simple_manifest.csv') }
      include_examples "successful conversion to csv"
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
