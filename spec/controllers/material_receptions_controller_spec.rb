require 'rails_helper'
require 'webmock/rspec'

RSpec.describe MaterialReceptionsController, type: :controller do
  describe "When scanning a barcode" do
    setup do

      @request.env['devise.mapping'] = Devise.mappings[:user]

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


      @user = FactoryGirl.create(:user)
      sign_in(@user)

      @labware_type = FactoryGirl.create(:labware_type, {:row_is_alpha => true})

      @submission = FactoryGirl.create(:material_submission, user: @user)

      @labware = Labware.create(material_submission: @submission, labware_index: 1, barcode: "AKER-1")

      allow(request.env['warden']).to receive(:authenticate!).and_return(@user)

      @submission.labwares << @labware

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

    it "adds the barcode to the list if the barcode exists and has not been received yet" do
      @labware.update_attributes(print_count: 1, barcode: 'AKER_500', container_id: 'testing-uuid')
      @material_submission = FactoryGirl.create(:material_submission, user: @user)
      @labware.update_attributes(material_submission_id: @material_submission.id)

      stub_request(:get, Rails.configuration.material_url+"/containers/#{@labware.container_id}").
         with(:headers => {'Content-Type'=>'application/json'}).
         to_return(:status => 200, :body => @labware.attributes.to_json, :headers => {})
      stub_request(:get, Rails.configuration.material_url+"/containers?where=%7B%22barcode%22:%22#{@labware.barcode}%22%7D").
         with(:headers => {'Content-Type'=>'application/json'}).
         to_return(:status => 200, :body => {"_items" => [@labware.attributes]}.to_json)

      count = MaterialReception.all.count
      post :create, params: { :material_reception => {:barcode_value => @labware.barcode }}
      expect(response).to have_http_status(:ok)
      MaterialReception.all.reload
      expect(MaterialReception.all.count).to eq(count+1)
    end
  end
end
