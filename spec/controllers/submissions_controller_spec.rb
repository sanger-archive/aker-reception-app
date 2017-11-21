require 'rails_helper'
require 'webmock/rspec'
require 'ostruct'

RSpec.describe SubmissionsController, type: :controller do

  def step_params(material_submission, step_name)
    p = {
        material_submission: case step_name
          when :labware
            {
              supply_labwares: true,
              supply_decappers: true,
              no_of_labwares_required: 1,
              status: 'labware',
              labware_type_id: labware_type.id
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
              contact_id: contact.id
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
          "scientific_name" => species,
        }
      }
    end
    data
  end

  let(:labware_type) do
    FactoryBot.create :labware_type, {
      num_of_cols: 1,
      num_of_rows: 1,
      uses_decapper: true,
    }
  end

  let(:contact) { FactoryBot.create(:contact) }

  describe "Using the steps defined by wicked" do
    setup do
      schema = 
        {
          "required":[
            "gender",
            "donor_id",
            "phenotype",
            "supplier_name",
            "scientific_name"
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
            "scientific_name":{
              "required":true,
              "type":"string",
              "enum":[
                "Homo Sapiens",
                "Mouse"
              ]
            }
          }
        }
      

      request_headers = {'Content-Type'=>'application/json', 'Accept'=>'application/json'}

      allow(MatconClient::Material).to receive(:schema).and_return(schema.as_json)
    end

    let(:user) { OpenStruct.new(email: 'other@sanger.ac.uk', groups: ['world']) }
    let(:material_submission) { FactoryBot.create(:material_submission, owner_email: user.email) }

    context 'when user is not authenticated' do
      let(:login_url) { Rails.configuration.login_url+'?'+{redirect_url:request.original_url}.to_query }
      
      it 'redirects to the login page' do
        put :update, step_params(material_submission, :labware)
        expect(response).to redirect_to(login_url)
      end
    end

    context 'when user is authenticated' do
      before do
        allow(controller).to receive(:check_credentials)
        allow(controller).to receive(:current_user).and_return(user)
      end

      it "does not update the submission if the state is not pending (i.e. broken)" do
        allow_any_instance_of(DispatchService).to receive(:process).and_raise  "This step fails"
        allow_any_instance_of(ProvenanceService).to receive(:validate).and_return []

        put :update, step_params(material_submission, :labware)
        material_submission.reload

        put :biomaterial_data, step_params(material_submission, :provenance)
        material_submission.reload

        put :update, step_params(material_submission, :dispatch)
        material_submission.reload

        put :update, step_params(material_submission, :dispatch)
        material_submission.reload

        expect(material_submission.status).to eq('broken')
        expect(flash[:error]).to match("This submission cannot be updated.")
      end

      it "does not complete the submission if any steps have not been performed" do
        put :update, step_params(material_submission, :dispatch)
        material_submission.reload
        expect(material_submission.status).not_to eq('active')
      end

      it "does not update the submission state if any required data of steps has not been provided" do
        allow_any_instance_of(ProvenanceService).to receive(:validate).and_return []

        put :update, step_params(material_submission, :labware)
        material_submission.reload

        put :biomaterial_data, step_params(material_submission, :provenance)
        material_submission.reload

        put :update, step_params(material_submission, :dispatch_contact_error)
        material_submission.reload

        expect(material_submission.status).to eq('dispatch')
      end

      it "updates the submission state to active when all steps are successful and DispatchSerivce#process returns true" do
        allow_any_instance_of(ProvenanceService).to receive(:validate).and_return []
        allow_any_instance_of(DispatchService).to receive(:process).and_return(true)

        put :update, step_params(material_submission, :labware)
        material_submission.reload
        expect(material_submission.supply_decappers).to eq(true)

        put :biomaterial_data, step_params(material_submission, :provenance)
        material_submission.reload

        put :update, step_params(material_submission, :dispatch)
        material_submission.reload

        expect(flash[:notice]).to match('Your submission has been created')
        expect(material_submission.status).to eq('active')
      end

      it "does not update submission status if DispatchSerivce#process returns false" do
        allow_any_instance_of(DispatchService).to receive(:process).and_return false
        allow_any_instance_of(ProvenanceService).to receive(:validate).and_return []

        put :update, step_params(material_submission, :labware)
        material_submission.reload

        put :biomaterial_data, step_params(material_submission, :provenance)
        material_submission.reload

        put :update, step_params(material_submission, :dispatch)
        material_submission.reload

        expect(material_submission.status).to eq('dispatch')
        expect(flash[:error]).to match("The submission could not be created")
      end

      it "updates the submission status to broken if DispatchSerivce#process raises an exception" do
        allow_any_instance_of(DispatchService).to receive(:process).and_raise  "This step fails"
        allow_any_instance_of(ProvenanceService).to receive(:validate).and_return []

        put :update, step_params(material_submission, :labware)
        material_submission.reload

        put :biomaterial_data, step_params(material_submission, :provenance)
        material_submission.reload

        put :update, step_params(material_submission, :dispatch)
        material_submission.reload

        expect(material_submission.status).to eq('broken')
        expect(flash[:error]).to match("There has been a problem with the submission. Please contact support.")
      end

      it "updates the labware contents if ProvenanceServive#set_biomaterial_data returns no errors" do
        allow_any_instance_of(ProvenanceService).to receive(:validate).and_return []

        put :update, step_params(material_submission, :labware)
        material_submission.reload

        expect(material_submission.labwares.first.contents).to eq nil

        put :biomaterial_data, step_params(material_submission, :provenance)
        material_submission.reload

        expect(material_submission.labwares.first.contents).not_to eq nil
        expect(material_submission.status).to eq('dispatch')
      end

      it "does not update submission status if ProvenanceServive#set_biomaterial_data returns errors" do
        allow_any_instance_of(ProvenanceService).to receive(:set_biomaterial_data).and_return [false, ['error', 'error']]

        put :update, step_params(material_submission, :labware)
        material_submission.reload

        expect(material_submission.labwares.first.contents).to eq nil

        put :biomaterial_data, step_params(material_submission, :provenance)
        material_submission.reload

        expect(material_submission.status).to eq('provenance')
      end

      it "moves on to the ethics step if the labware contains human material" do
        allow_any_instance_of(ProvenanceService).to receive(:validate).and_return []
        put :update, step_params(material_submission, :labware)
        material_submission.reload
        put :biomaterial_data, step_params(material_submission, :provenance_human)
        material_submission.reload
        expect(material_submission.status).to eq('ethics')
      end

      it "skips the ethics step if the labware does not contain human material" do
        allow_any_instance_of(ProvenanceService).to receive(:validate).and_return []
        put :update, step_params(material_submission, :labware)
        material_submission.reload
        put :biomaterial_data, step_params(material_submission, :provenance)
        material_submission.reload
        expect(material_submission.status).to eq('dispatch')
      end

      it "runs ethics in the ethics service" do
        ethics_params = {
          hmdmc_1: '12',
          hmdmc_2: '345',
          confirm_hmdmc_not_required: '0',
        }

        allow_any_instance_of(ProvenanceService).to receive(:validate).and_return []
        put :update, step_params(material_submission, :labware)
        put :biomaterial_data, step_params(material_submission, :provenance)
        material_submission.reload

        params = step_params(material_submission, :ethics)
        params[:params].merge!(ethics_params)
        ac_par = ActionController::Parameters.new(ethics_params)
        ac_par.permit!
        expect_any_instance_of(EthicsService).to receive(:update).with(ac_par, user.email)
        put :update, params
        material_submission.reload
      end
    end

  end

end
