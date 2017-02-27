require 'rails_helper'
require 'webmock/rspec'

RSpec.describe MaterialReceptionsController, type: :controller do
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


      @labware_type = FactoryGirl.create(:labware_type, {:row_is_alpha => true})
      @material_submission_labware = @labware_type.create_labware
      @submission = FactoryGirl.create(:material_submission)
      @submission.labwares << @material_submission_labware
      @labware = @material_submission_labware.labware

      stub_request(:get, Rails.configuration.material_url+"/containers?where=%7B%22barcode%22:%22#{@labware.barcode}%22%7D").
         with(:headers => {'Content-Type'=>'application/json'}).
         to_return(:status => 200, :body => {"_items" => []}.to_json)


    end

    it "does not add the barcode to the list if the barcode does not exist" do
      stub_request(:get, Rails.configuration.material_url+"/containers?where=%7B%22barcode%22:%22NOT_EXISTS%22%7D").
         with(:headers => {'Content-Type'=>'application/json'}).
         to_return(:status => 200, :body => {"_items" => []}.to_json)

      count = MaterialReception.all.count
      post :create, { :material_reception => {:barcode_value => 'NOT_EXISTS'}}
      MaterialReception.all.reload
      expect(MaterialReception.all.count).to eq(count)
    end

    it "does not add the barcode to the list if the barcode has already been received" do
      MaterialReception.create(:labware_id => @labware.uuid)
      count = MaterialReception.all.count
      post :create, { :material_reception => {:barcode_value => @labware.barcode}}
      MaterialReception.all.reload
      expect(MaterialReception.all.count).to eq(count)
    end

    it "does not add the barcode to the list if the barcode has not been printed" do
      @labware.update_attributes(print_count: 0)
      count = MaterialReception.all.count
      post :create, { :material_reception => {:barcode_value => @labware.barcode}}
      MaterialReception.all.reload
      expect(MaterialReception.all.count).to eq(count)
    end

    it "adds the barcode to the list if the barcode exists and has not been received yet" do
      count = MaterialReception.all.count
      @labware.barcode.update_attributes(print_count: 1)
      post :create, { :material_reception => {:barcode_value => @labware.barcode }}
      MaterialReception.all.reload
      expect(MaterialReception.all.count).to eq(count+1)
    end
  end
end
