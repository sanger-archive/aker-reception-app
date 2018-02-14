require 'rails_helper'
require 'webmock/rspec'
require 'ostruct'

RSpec.describe MaterialReceptionsController, type: :controller do
  it_behaves_like 'service that validates credentials', [:index]

  let(:expected_redirect) { Rails.configuration.login_url+'?'+{redirect_url: request.original_url}.to_query }

  context 'when no JWT is included' do
    before do
      @user = OpenStruct.new(email: 'other@sanger.ac.uk', groups: %w[world team252])
      @submission = FactoryBot.create(:material_submission, owner_email: @user.email)
    end
    it 'redirects to the login page' do
      get :index
      expect(response).to redirect_to(expected_redirect)
    end
  end

  context 'when JWT is included' do
    before do
      @user = OpenStruct.new(email: 'other@sanger.ac.uk', groups: %w[world team252])
      allow(controller).to receive(:check_credentials)
      allow(controller).to receive(:current_user).and_return(@user)

      @submission = FactoryBot.create(:material_submission, owner_email: @user.email)
      @labware = Labware.create(material_submission: @submission, labware_index: 1, barcode: "AKER-1")
      @submission.labwares << @labware
      @labware_type = FactoryBot.create(:labware_type, {:row_is_alpha => true})
    end

    describe "When scanning a barcode" do
      setup do
        stub_request(:post, Rails.configuration.material_url+'/containers').
           with(:body => {"num_of_cols"=> 12,"num_of_rows"=>8,"col_is_alpha"=>false,"row_is_alpha"=>true}.to_json,
                :headers => {'Accept'=>'*/*', 'Accept-Encoding'=>'gzip;q=1.0,deflate;q=0.6,identity;q=0.3',
                  'Content-Type'=>'application/json',
                  }).
           to_return(:status => 200, :body => {
              "_updated"=> "Wed, 22 Feb 2017 23:30:11 GMT",
              "num_of_cols"=> 12,
              "barcode"=> "AKER-110",
              "num_of_rows"=> 8,
              "col_is_alpha"=> false,
              "_links"=> {
              "self"=> {
              "href"=> "containers/382ce837-478c-49a3-86a8-7af34bb898cf",
              "title"=> "Container"
              },
              "collection"=> {
              "href"=> "containers",
              "title"=> "containers"
              },
              "parent"=> {
              "href"=> "/",
              "title"=> "home"
              }
              },
              "_created"=> "Wed, 22 Feb 2017 22:42:38 GMT",
              "row_is_alpha"=> true,
              "_id"=> "382ce837-478c-49a3-86a8-7af34bb898cf"
              }.to_json, :headers => {})


        stub_request(:get, Rails.configuration.material_url+'/containers/382ce837-478c-49a3-86a8-7af34bb898cf').
           with(
                :headers => {'Accept'=>'*/*', 'Accept-Encoding'=>'gzip;q=1.0,deflate;q=0.6,identity;q=0.3',
                  'Content-Type'=>'application/json',
                  }).
           to_return(:status => 200, :body => {
              "_updated"=> "Wed, 22 Feb 2017 23:30:11 GMT",
              "num_of_cols"=> 12,
              "barcode"=> "AKER-110",
              "num_of_rows"=> 8,
              "col_is_alpha"=> false,
              "_links"=> {
              "self"=> {
              "href"=> "containers/382ce837-478c-49a3-86a8-7af34bb898cf",
              "title"=> "Container"
              },
              "collection"=> {
              "href"=> "containers",
              "title"=> "containers"
              },
              "parent"=> {
              "href"=> "/",
              "title"=> "home"
              }
              },
              "_created"=> "Wed, 22 Feb 2017 22:42:38 GMT",
              "row_is_alpha"=> true,
              "_id"=> "382ce837-478c-49a3-86a8-7af34bb898cf"
              }.to_json, :headers => {})

        stub_request(:get, Rails.configuration.material_url+"/containers?where=%7B%22barcode%22:%22#{@labware.barcode}%22%7D").
           with(:headers => {'Content-Type'=>'application/json'}).
           to_return(:status => 200, :body => {"_items" => []}.to_json)
      end

      it "does not add the barcode to the list if the barcode does not exist" do
        stub_request(:get, Rails.configuration.material_url+"/containers?where=%7B%22barcode%22:%22NOT_EXISTS%22%7D").
           with(:headers => {'Content-Type'=>'application/json'}).
           to_return(:status => 200, :body => {"_items" => []}.to_json)

        count = MaterialReception.all.count
        post :create, params: { :material_reception => { :barcode_value => 'NOT_EXISTS'} }
        MaterialReception.all.reload
        expect(MaterialReception.all.count).to eq(count)
      end

      it "does not add the barcode to the list if the barcode has already been received" do
        MaterialReception.create(:labware_id => @labware.id)
        count = MaterialReception.all.count
        post :create, params: { :material_reception => {:barcode_value => @labware.barcode}}
        MaterialReception.all.reload
        expect(MaterialReception.all.count).to eq(count)
      end

      it "does not add the barcode to the list if the barcode has not been printed" do
        @labware.assign_attributes(print_count: 0)
        count = MaterialReception.all.count
        post :create, params: { :material_reception => {:barcode_value => @labware.barcode}}
        MaterialReception.all.reload
        expect(MaterialReception.all.count).to eq(count)
      end

      it "does not add the barcode to the list if the barcode has not been dispatched" do
        count = MaterialReception.all.count
        post :create, params: { :material_reception => {:barcode_value => @labware.barcode}}
        MaterialReception.all.reload
        expect(MaterialReception.all.count).to eq(count)
      end

      it "adds the barcode to the list if the barcode exists and has not been received yet" do
        material_double = instance_double("MatconClient::Material", update_attributes: true)
        allow(MatconClient::Material).to receive(:new).and_return(material_double)
        labware = create(:printed_with_contents_labware, barcode: 'AKER_500', container_id: 'testing-uuid')

        stub_request(:get, Rails.configuration.material_url+"/containers/#{labware.container_id}").
           with(:headers => {'Content-Type'=>'application/json'}).
           to_return(:status => 200, :body => labware.attributes.to_json, :headers => {})
        stub_request(:get, Rails.configuration.material_url+"/containers?where=%7B%22barcode%22:%22#{labware.barcode}%22%7D").
           with(:headers => {'Content-Type'=>'application/json'}).
           to_return(:status => 200, :body => {"_items" => [labware.attributes]}.to_json)

        count = MaterialReception.all.count
        labware.material_submission.update_attributes(dispatched: true)
        post :create, params: { :material_reception => {:barcode_value => labware.barcode }}
        expect(response).to have_http_status(:ok)
        MaterialReception.all.reload
        expect(MaterialReception.all.count).to eq(count+1)
      end
    end
  end

end
