require 'rails_helper'
require 'webmock/rspec'

def step_params(material_submission, step_name)
  p = {
      material_submission: case step_name
        when :labware
          {
            supply_labwares: true,
            no_of_labwares_required: 1,
            status: 'labware',
            labware_type_id: @labware_type.id
          }
        when :provenance
          {
            status: 'provenance',
            labware: labware_attributes_for(material_submission.labwares, 'Mouse')
          }
        when :provenance_human
          step_name = :provenance
          {
            status: 'provenance',
            labware: labware_attributes_for(material_submission.labwares, 'Homo Sapiens')
          }
        when :ethics
          {
            status: 'ethics',
          }
        when :dispatch
          {
            status: 'dispatch',
            address: 'Testing address',
            email: 'test@email.com',
            contact_id: @contact.id
          }
        when :dispatch_contact_error
          step_name = :dispatch
          {
            status: 'dispatch',
            contact_attributes: {email: ''},
            address: 'Testing address',
          }
        end
      }.merge(
        {
          format: (step_name == :provenance) ? 'json' : 'html',
          material_submission_id: material_submission.id,
          id: step_name
        }
      )
  return { params: p }
end

def labware_attributes_for(labwares, species)
  data = {}
  labwares.each do |labware|
    data[labware.labware_index] = {
      "1" => {
        "gender" => "male",
        "donor_id" => "d",
        "phenotype" => "p",
        "supplier_name" => "s",
        "common_name" => species,
      }
    }
  end
  data
end

RSpec.describe SubmissionsController, type: :controller do
  describe "Using the steps defined by wicked" do
    setup do
      @request.env['devise.mapping'] = Devise.mappings[:user]

      @user = FactoryGirl.create(:user)
      sign_in(@user)

      @labware_type = FactoryGirl.create :labware_type, {
        num_of_cols: 1,
        num_of_rows: 1
      }
      @material_submission = FactoryGirl.create(:material_submission, user: @user)
      @contact = FactoryGirl.create :contact
      schema = %Q(
        {
          "required":[
            "gender",
            "donor_id",
            "phenotype",
            "supplier_name",
            "common_name"
          ],
          "type":"object",
          "properties":{
            "gender":{
              "required":true,
              "type":"string",
              "enum":[
                "male",
                "female",
                "unknown"
               ]
            },
            "date_of_receipt":{
              "type":"string",
              "format":"date"
            },
            "material_type":{
              "enum":[
                "blood",
                "dna"
              ],
              "type":"string"
            },
            "donor_id":{
              "required":true,
              "type":"string"
            },
            "phenotype":{
              "required":true,
              "type":"string"
            },
            "supplier_name":{
              "required":true,
              "type":"string"
            },
            "common_name":{
              "required":true,
              "type":"string",
              "enum":[
                "Homo Sapiens",
                "Mouse"
              ]
            }
          }
        }
      )

    request_headers = {'Content-Type'=>'application/json', 'Accept'=>'application/json'}

    stub_request(:get, "http://localhost:5000/materials/json_schema").
       with(headers: request_headers).
       to_return(status: 200, body: schema, headers: {})
    end

    it "does not update the submission if the state is not pending (ie broken)" do
      allow_any_instance_of(DispatchService).to receive(:process).and_raise  "This step fails"
      allow_any_instance_of(ProvenanceService).to receive(:validate).and_return []


      put :update, step_params(@material_submission, :labware)
      @material_submission.reload

      put :biomaterial_data, step_params(@material_submission, :provenance)
      @material_submission.reload

      put :update, step_params(@material_submission, :dispatch)
      @material_submission.reload

      put :update, step_params(@material_submission, :dispatch)
      @material_submission.reload

      expect(@material_submission.status).to eq('broken')
      expect(flash[:error]).to match("This submission cannot be updated.")
    end

    it "does not complete the submission if any steps have not been performed" do
      put :update, step_params(@material_submission, :dispatch)
      @material_submission.reload
      expect(@material_submission.status).not_to eq('active')
    end

    it "does not update the submission state if any required data of steps has not been provided" do
      allow_any_instance_of(ProvenanceService).to receive(:validate).and_return []

      put :update, step_params(@material_submission, :labware)
      @material_submission.reload

      put :biomaterial_data, step_params(@material_submission, :provenance)
      @material_submission.reload

      put :update, step_params(@material_submission, :dispatch_contact_error)
      @material_submission.reload

      expect(@material_submission.status).to eq('dispatch')
    end

    it "updates the submission state to active when all steps are successful and DispatchSerivce#process returns true" do
      allow_any_instance_of(ProvenanceService).to receive(:validate).and_return []
      allow_any_instance_of(DispatchService).to receive(:process).and_return(true)

      put :update, step_params(@material_submission, :labware)
      @material_submission.reload

      put :biomaterial_data, step_params(@material_submission, :provenance)
      @material_submission.reload

      put :update, step_params(@material_submission, :dispatch)
      @material_submission.reload

      expect(flash[:notice]).to match('Your submission has been created')
      expect(@material_submission.status).to eq('active')
    end

    it "does not update submission status if DispatchSerivce#process returns false" do
      allow_any_instance_of(DispatchService).to receive(:process).and_return false
      allow_any_instance_of(ProvenanceService).to receive(:validate).and_return []

      put :update, step_params(@material_submission, :labware)
      @material_submission.reload

      put :biomaterial_data, step_params(@material_submission, :provenance)
      @material_submission.reload

      put :update, step_params(@material_submission, :dispatch)
      @material_submission.reload

      expect(@material_submission.status).to eq('dispatch')
      expect(flash[:error]).to match("The submission could not be created")
    end

    it "updates the submission status to broken if DispatchSerivce#process raises an exception" do
      allow_any_instance_of(DispatchService).to receive(:process).and_raise  "This step fails"
      allow_any_instance_of(ProvenanceService).to receive(:validate).and_return []

      put :update, step_params(@material_submission, :labware)
      @material_submission.reload

      put :biomaterial_data, step_params(@material_submission, :provenance)
      @material_submission.reload

      put :update, step_params(@material_submission, :dispatch)
      @material_submission.reload

      expect(@material_submission.status).to eq('broken')
      expect(flash[:error]).to match("There has been a problem with the submission. Please contact support.")
    end

    it "updates the labware contents if ProvenanceServive#set_biomaterial_data returns no errors" do
      allow_any_instance_of(ProvenanceService).to receive(:validate).and_return []

      put :update, step_params(@material_submission, :labware)
      @material_submission.reload

      expect(@material_submission.labwares.first.contents).to eq nil

      put :biomaterial_data, step_params(@material_submission, :provenance)
      @material_submission.reload

      expect(@material_submission.labwares.first.contents).not_to eq nil
      expect(@material_submission.status).to eq('dispatch')
    end

    it "does not update submission status if ProvenanceServive#set_biomaterial_data returns errors" do
      allow_any_instance_of(ProvenanceService).to receive(:set_biomaterial_data).and_return [false, ['error', 'error']]

      put :update, step_params(@material_submission, :labware)
      @material_submission.reload

      expect(@material_submission.labwares.first.contents).to eq nil

      put :biomaterial_data, step_params(@material_submission, :provenance)
      @material_submission.reload

      expect(@material_submission.status).to eq('provenance')
    end

    it "moves on to the ethics step if the labware contains human material" do
      allow_any_instance_of(ProvenanceService).to receive(:validate).and_return []
      put :update, step_params(@material_submission, :labware)
      @material_submission.reload
      put :biomaterial_data, step_params(@material_submission, :provenance_human)
      @material_submission.reload
      expect(@material_submission.status).to eq('ethics')
    end

    it "skips the ethics step if the labware does not contain human material" do
      allow_any_instance_of(ProvenanceService).to receive(:validate).and_return []
      put :update, step_params(@material_submission, :labware)
      @material_submission.reload
      put :biomaterial_data, step_params(@material_submission, :provenance)
      @material_submission.reload
      expect(@material_submission.status).to eq('dispatch')
    end

    it "runs ethics in the ethics service" do
      ethics_params = {
        hmdmc_1: '12',
        hmdmc_2: '345',
        confirm_hmdmc_not_required: '0',
      }
      params = step_params(@material_submission, :ethics)
      params[:params].merge!(ethics_params)
      ac_par = ActionController::Parameters.new(ethics_params)
      ac_par.permit!
      expect_any_instance_of(EthicsService).to receive(:update).with(ac_par, @user.email)
      put :update, params
      @material_submission.reload
    end

  end

end
