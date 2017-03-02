require 'rails_helper'
require 'webmock/rspec'

def step_params(material_submission, step_name)
  {:params => {
    :material_submission => case step_name
      when :labware
        {
              :supply_labwares => true,
              :no_of_labwares_required => 1,
              :status => 'labware',
              :labware_type_id => @labware_type.id
        }
      when :provenance
        {

              :status => 'provenance',
              :labwares_attributes => plate_attributes_for(material_submission.labwares)
        }
      when :dispatch
        {
          :status => 'active',
          :address => 'Testing address',
          :email => 'test@email.com',
          :contact_id => @contact.id
        }
      when :dispatch_contact_error
        step_name = :dispatch
        {
          :status => 'active',
          :contact_attributes => {:email => ''},
          :address => 'Testing address',
        }
      end
    }.merge(
      {
        :format => (step_name == :provenance) ? 'json' : 'html',
        :material_submission_id => material_submission.id,
        :id => step_name
      }
    )
  }
end


def wells_attributes_for(plate)
  plate.wells.each_with_index.reduce({}) do |memo, list|
    well,index = list[0],list[1]
    memo[index.to_s] = {
      :uuid => well.id.to_s,
      :position => well.position,
      :biomaterial_attributes => {
        #{}"0" => {
          :supplier_name => 'Test',
          :donor_name => 'Test',
          :gender => 'Test',
          :common_name => 'Test',
          :phenotype => 'Test'
        #}
      }
    }
    memo
  end
end

def plate_attributes_for(labwares)
  labwares.each_with_index.reduce({}) do |mlabware, list|
    plate, plate_idx = list[0],list[1]
    mlabware[plate_idx.to_s] = {
      :uuid => plate.id.to_s,
      :wells_attributes => wells_attributes_for(plate)
    }
    mlabware
  end

end


RSpec.describe SubmissionsController, type: :controller do
  describe "Using the steps defined by wicked" do
    setup do
      @labware_type = FactoryGirl.create :labware_type, {
        :num_of_cols => 1, 
        :num_of_rows => 1
      }
      @material_submission = FactoryGirl.create :material_submission
      @contact = FactoryGirl.create :contact

      stub_request(:get, "#{Rails.configuration.material_url}/materials/schema").
         with(:headers => {
          'Content-Type'=>'text/json',
          }).
         to_return(:status => 200, :body => "{}", :headers => {})


      @material_obj = {"common_name"=>"Test", "donor_id"=>"Test", "gender"=>"Test", "phenotype"=>"Test", "supplier_name"=>"Test"}
      stub_request(:post, "#{Rails.configuration.material_url}/materials").
         with(:body => "{\"supplier_name\":\"Test\",\"donor_id\":\"Test\",\"gender\":\"Test\",\"common_name\":\"Test\",\"phenotype\":\"Test\"}",
              :headers => { 'Content-Type'=>'application/json'}).
         to_return(:status => 200, :body => "{}", :headers => {})

      stub_request(:put, "#{Rails.configuration.material_url}/materials").
         with(:body => @material_obj.to_json,
              :headers => { 'Content-Type'=>'application/json'}).
         to_return(:status => 200, :body => "{}", :headers => {})


      labware_json = {
        "_updated"=>"Wed, 22 Feb 2017 23:30:11 GMT",
        "num_of_cols"=>1,
        "barcode"=>"AKER-110",
        "num_of_rows"=>1,
        "col_is_alpha"=>false,
        "slots" => 2.times.map do 
            {
              "address": "A:1",
              "material": "uuid_for_material"
            }
        end,
        "_links"=>{
        "self"=>{
        "href"=>"containers/382ce837-478c-49a3-86a8-7af34bb898cf",
        "title"=>"Container"
        },
        "collection"=>{
        "href"=>"containers",
        "title"=>"containers"
        },
        "parent"=>{
        "href"=>"/",
        "title"=>"home"
        }
        },
        "_created"=>"Wed, 22 Feb 2017 22:42:38 GMT",
        "row_is_alpha"=>true,
        "_id"=>"382ce837-478c-49a3-86a8-7af34bb898cf"
        }.to_json

      stub_request(:post, "#{Rails.configuration.material_url}/containers").
         with(:body => "{\"num_of_cols\":1,\"num_of_rows\":1,\"col_is_alpha\":false,\"row_is_alpha\":false}", 
          :headers => { 'Content-Type'=>'application/json'}).
         to_return(:status => 200, :body => labware_json, :headers => {})

      stub_request(:any, "#{Rails.configuration.material_url}/containers/382ce837-478c-49a3-86a8-7af34bb898cf").
         to_return(:status => 200, :body => labware_json, :headers => {})

      stub_request(:get, "#{Rails.configuration.material_url}/materials/uuid_for_material").
         with(:headers => {'Content-Type'=>'application/json'}).
         to_return(:status => 200, :body => @material_obj.to_json, :headers => {})         

      stub_request(:put, "http://localhost:5000/materials/uuid_for_material").
         with(:body => "{\"supplier_name\":\"Test\",\"donor_id\":\"Test\",\"gender\":\"Test\",\"common_name\":\"Test\",\"phenotype\":\"Test\"}",
          :headers => { 'Content-Type'=>'application/json'}).
         to_return(:status => 200, :body => @material_obj.to_json, :headers => {})




      @uuid = SecureRandom.uuid

      stub_request(:post, "#{Rails.configuration.set_url}").
         with(:body => "{\"data\":{\"type\":\"sets\",\"attributes\":{\"name\":\"Submission 1\"}}}",
              :headers => {'Content-Type'=>'application/vnd.api+json'}).
         to_return(:status => 200, :body => "{\"data\":{\"id\":\"#{@uuid}\",\"attributes\":{\"name\":\"testing-set-1\"}}}", :headers => {})


      stub_request(:post, "#{Rails.configuration.ownership_url}/batch").
         with(:headers => {'Content-Type'=>'application/x-www-form-urlencoded'}).
         to_return(:status => 200, :body => "{}", :headers => {})

      stub_request(:post, "#{Rails.configuration.ownership_url}").
         with(:body => {"ownership"=>{"model_id"=>"#{@uuid}", "model_type"=>"set", "owner_id"=>"test@email.com"}},
              :headers => {'Content-Type'=>'application/x-www-form-urlencoded'}).
         to_return(:status => 200, :body => "{}", :headers => {})

      stub_request(:post, "#{Rails.configuration.set_url}/#{@uuid}/relationships/materials").
         with(:body =>"{\"data\":[{\"id\":null,\"type\":\"materials\"},{\"id\":null,\"type\":\"materials\"}]}",
              :headers => {'Content-Type'=>'application/vnd.api+json'}).
         to_return(:status => 200, :body => "{}", :headers => {})

       stub_request(:get, "#{Rails.configuration.set_url}/#{@uuid}/relationships/materials").
         with(:headers => {'Content-Type'=>'application/vnd.api+json'}).
         to_return(:status => 200, :body => "{}", :headers => {})

        stub_request(:get, "#{Rails.configuration.set_url}/#{@uuid}/relationships/materials").
         with(:headers => {'Accept'=>'application/vnd.api+json'}).
         to_return(:status => 200, :body => "{}", :headers => {})
    end

    it "does not update the submission state if any steps have not been performed" do
      put :update, step_params(@material_submission, :dispatch)
      @material_submission.reload
      expect(@material_submission.status).not_to eq('active')
    end

    it "does not update the submission state if any required data of steps has not been provided" do
      put :update, step_params(@material_submission, :labware)
      @material_submission.reload

      put :update, step_params(@material_submission, :provenance)
      @material_submission.reload
      put :update, step_params(@material_submission, :dispatch_contact_error)
      @material_submission.reload
      expect(@material_submission.status).not_to eq('active')
    end


    it "updates the submission state to active when all the required data of the steps has been provided" do

      stub_request(:patch, "#{Rails.configuration.set_url}/#{@uuid}").
         with(:body => "{\"data\":{\"type\":\"sets\",\"id\":\"#{@uuid}\",\"attributes\":{\"locked\":true}}}",
              :headers => {'Accept'=>'application/vnd.api+json'}).
         to_return(:status => 200, :body => {}.to_json, :headers => {})

      put :update, step_params(@material_submission, :labware)
      @material_submission.reload

      put :update, step_params(@material_submission, :provenance)
      @material_submission.reload
      put :update, step_params(@material_submission, :dispatch)
      @material_submission.reload
      expect(@material_submission.status).to eq('active')
    end
  end
end
