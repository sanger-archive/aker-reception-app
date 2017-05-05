require 'rails_helper'
require 'webmock/rspec'

RSpec.describe ClaimSubmissionsController, type: :controller do
	describe "claiming submissions" do

    setup do
      @request.env['devise.mapping'] = Devise.mappings[:user]

      @user = FactoryGirl.create(:user)
      @contact = FactoryGirl.create(:contact, email: @user.email)
      sign_in(@user)

      allow(request.env['warden']).to receive(:authenticate!).and_return(@user)
    end

    context "#index" do
      it 'shows sets belonging to the user' do
        @material_submission = FactoryGirl.create(:material_submission, contact: @contact, status: MaterialSubmission.AWAITING)

        get :index, params: {}

        submissions = controller.instance_variable_get("@submissions")
        expect(submissions.length).to eq 1
      end
    end

    context "#claim" do
      it "adds a set to a collection" do

        @set_uuid = SecureRandom.uuid
        @material_uuid = SecureRandom.uuid

        request_headers = {'Content-Type'=>'application/vnd.api+json', 'Accept'=>'application/vnd.api+json'}
        response_headers = {'Content-Type'=>'application/vnd.api+json'}

        @set_obj = {data: { attributes: { id: "#{@set_uuid}", "meta"=>{"size"=>1}, "type"=>"sets", "name"=>"set-test-01", "owner_id"=>nil, "created_at"=>"2017-05-04T10:19:09.855Z", "locked"=>false } } }

        stub_request(:get, "#{Rails.configuration.set_url}sets/#{@set_uuid}").
        with(:headers => request_headers).
        to_return(:status => 200, :body => @set_obj.to_json, :headers => response_headers)


        @material_id_obj = {data:[{id: "#{@material_uuid}", type: "materials"}]}
        stub_request(:post, "#{Rails.configuration.set_url}sets/#{@set_uuid}/relationships/materials").
        with(body: @material_id_obj.to_json,
              headers: request_headers).
        to_return(status: 200, body: "", headers: response_headers)

        @labware_type = FactoryGirl.create(:labware_type, {:row_is_alpha => true})
        @submission = FactoryGirl.create(:material_submission, user: @user, status: MaterialSubmission.AWAITING)
        @labware = Labware.create(material_submission: @submission, labware_index: 1, barcode: "AKER-1", contents: {"1": { id: "#{@material_uuid}" } })

        @submission.labwares << @labware

        post :claim, {:params => { :submission_ids => [@submission.id], :collection_id =>  @set_uuid } }

        @submission.reload
        expect(@submission.status).to eq('claimed')
      end
    end

	end
end

