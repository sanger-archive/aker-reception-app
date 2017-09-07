require 'rails_helper'
require 'webmock/rspec'

RSpec.describe ClaimSubmissionsController, type: :controller do

  def webmock_stamp(uuid)
    stub_request(:get, "#{Rails.configuration.stamp_url}stamps/#{@stamp_id}").
     with(headers: {'Accept'=>'application/vnd.api+json'}).
     to_return(status: 200, body: {"data":{"id":@stamp_id,"type":"stamps","links":{"self":"#{Rails.configuration.stamp_url}stamps/#{@stamp_id}"},"attributes":{"name":"my stamp","owner-id":"emr@sanger.ac.uk"},"relationships":{"permissions":{"links":{"self":"#{Rails.configuration.stamp_url}stamps/#{@stamp_id}/relationships/permissions","related":"#{Rails.configuration.stamp_url}stamps/#{@stamp_id}/permissions"}},"materials":{"links":{"self":"#{Rails.configuration.stamp_url}stamps/#{@stamp_id}/relationships/materials","related":"#{Rails.configuration.stamp_url}stamps/#{@stamp_id}/materials"}}}}}.to_json,
      headers: { 'Content-Type' => 'application/json'})


    stamp = double('stamp', id: uuid)

    allow(StampClient::Stamp).to receive(:find).and_return([stamp])
    stamp
  end

  setup do
    @request.env['devise.mapping'] = Devise.mappings[:user]

    @user = FactoryGirl.create(:user)
    @contact = FactoryGirl.create(:contact, email: @user.email)
    sign_in(@user)

    allow(request.env['warden']).to receive(:authenticate!).and_return(@user)

    stub_request(:get, "#{Rails.configuration.material_url}/materials/json_schema").
      to_return(status: 200, body: '{"required": ["supplier_name", "gender", "donor_id", "phenotype", "scientific_name"], "type": "object", "properties": {"available": {"default": false, "required": false, "type": "boolean"}, "hmdmc_not_required_confirmed_by": {"not_blank": true, "required": false, "type": "string"}, "gender": {"required": true, "type": "string", "allowed": ["male", "female", "unknown"]}, "date_of_receipt": {"type": "string", "format": "date"}, "material_type": {"type": "string", "allowed": ["blood", "dna"]}, "hmdmc_set_by": {"not_blank": true, "required": false, "type": "string", "required_with_hmdmc": true}, "hmdmc": {"hmdmc_format": true, "type": "string", "required": false}, "donor_id": {"required": true, "type": "string"}, "phenotype": {"required": true, "type": "string"}, "supplier_name": {"required": true, "type": "string"}, "scientific_name": {"required": true, "type": "string", "allowed": ["Homo Sapiens", "Mouse"]}, "parents": {"type": "list", "schema": {"type": "uuid", "data_relation": {"field": "_id", "resource": "materials", "embeddable": true}}}, "owner_id": {"type": "string"}}}', headers: { 'Content-Type' => 'application/json'})

    stub_request(:get, "#{Rails.configuration.stamp_url}stamps").
         with(headers: {'Accept'=>'application/vnd.api+json'}).
         to_return(status: 200, body: [].to_json, headers: { 'Content-Type' => 'application/json'})
  end

  describe "#index" do
    it 'shows submissions belonging to the user that are ready for claim' do
      subs = (0...2).map do |i|

        s = create(:material_submission,
          labware_type: create(:labware_type),
          supply_labwares: true,
          contact: @contact,
          address: 'Space',
        )
        s.no_of_labwares_required = 1
        s.status = MaterialSubmission.PRINTED
        s.save!
        s.reload
        lws = s.labwares
        lws.each { |lw| lw.update_attributes(print_count: 1) }
        if i==0
          create(:material_reception, labware_id: lws.first.id)
        end
        s
      end

      get :index, params: {}

      submissions = controller.instance_variable_get("@submissions")
      expect(submissions.length).to eq 1
      expect(submissions.first.id).to eq(subs[0].id)
    end
  end

  describe "#claim" do
    context 'when submission can be claimed' do
      it "marks the labware as claimed and makes the materials available" do
        @stamp_id = SecureRandom.uuid
        @stamp = webmock_stamp(@stamp_id)
        allow(@stamp).to receive(:apply_to)

        @set_uuid = SecureRandom.uuid
        @material_uuid = SecureRandom.uuid

        request_headers = {'Content-Type'=>'application/vnd.api+json', 'Accept'=>'application/vnd.api+json'}
        response_headers = {'Content-Type'=>'application/vnd.api+json'}

        @set_obj = {data: { attributes: { id: "#{@set_uuid}", "meta"=>{"size"=>1}, "type"=>"sets", "name"=>"set-test-01", "owner_id"=>nil, "created_at"=>"2017-05-04T10:19:09.855Z", "locked"=>false } } }

        stub_request(:get, "#{Rails.configuration.set_url}sets/#{@set_uuid}").
        with(headers: request_headers).
        to_return(status: 200, body: @set_obj.to_json, headers: response_headers)

        stub_request(:patch, "#{Rails.configuration.material_url}/materials/#{@material_uuid}").
          to_return(status: 200, body: "", headers: response_headers)

        @labware_type = FactoryGirl.create(:labware_type, {row_is_alpha: true})
        @submission = FactoryGirl.create(:material_submission, contact: @contact, status: MaterialSubmission.PRINTED)
        @labware = Labware.create(material_submission: @submission, labware_index: 1, barcode: "AKER-1", print_count: 1, contents: {"1": { id: "#{@material_uuid}" } })
        MaterialReception.create!(labware_id: @labware.id)

        @submission.labwares << @labware

        post :create, {params: { submission_ids: [@submission.id], stamp_id: @stamp_id } }

        assert_requested(:patch, "#{Rails.configuration.material_url}/materials/#{@material_uuid}", body: '{"available":true}')

        @submission.reload
        @submission.labwares.each { |lw| expect(lw).to be_claimed }
      end
    end

    context 'when submission not ready for claiming' do
      before do
        @set_uuid = SecureRandom.uuid
        @stamp_id = SecureRandom.uuid

        @submission = FactoryGirl.create(:material_submission, contact: @contact, status: MaterialSubmission.PRINTED)
        @labware = Labware.create(material_submission: @submission, labware_index: 1, barcode: "AKER-1", print_count: 1, contents: {"1": { id: "#{@material_uuid}" } })

        @submission.labwares << @labware
      end

      it "flashes an error" do
        post :create, {params: { submission_ids: [@submission.id], stamp_id: @stamp_id } }
        expect(flash[:error]).to match(/submissions.*cannot be claimed/)
      end

      it "doesn't update the labware as claimed" do
        expect_any_instance_of(MaterialSubmission).not_to receive(:claim_claimable_labwares)
        post :create, {params: { submission_ids: [@submission.id], stamp_id: @stamp_id } }
      end
    end
  end
end

