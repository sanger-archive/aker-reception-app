require 'rails_helper'
require 'ostruct'

RSpec.describe MaterialSubmissionsController, type: :controller do

  describe "#index" do
    context 'when no JWT is included' do
      it 'redirects to the login page' do
        get :index
        expect(response).to redirect_to(Rails.configuration.login_url)
      end
    end

    context 'when JWT is included' do
      before do
        user = OpenStruct.new(:email => 'other@sanger.ac.uk', :groups => ['world'])
        allow(controller).to receive(:current_user).and_return(user)

        sub1 = build(:material_submission, status: 'labware', owner_email: user.email)
        sub2 = build(:material_submission, status: 'dispatch', owner_email: user.email)
        sub3 = build(:material_submission, status: 'ACTIVE', owner_email: user.email)

        controller.instance_variable_set(:@pending_material_submissions, [sub1,sub2])
        controller.instance_variable_set(:@active_material_submissions, [sub3])
      end

      it 'has a list of incompleted submissions' do
        incompleted_submissions = controller.instance_variable_get("@pending_material_submissions")
        expect(incompleted_submissions.length).to eq 2
      end

      it 'has a list of completed submissions' do
        completed_submissions = controller.instance_variable_get("@active_material_submissions")
        expect(completed_submissions.length).to eq 1
      end
    end
  end

  describe "#destroy" do

    setup do
      @user = OpenStruct.new(:email => 'other@sanger.ac.uk', :groups => ['world'])
      allow(controller).to receive(:current_user).and_return(@user)

      @labware_type = FactoryGirl.create :labware_type, {
        :num_of_cols => 1,
        :num_of_rows => 1
      }
    end

    it 'deletes the material submission and labwares' do
      @material_uuid = SecureRandom.uuid
      @material_submission = FactoryGirl.create(:material_submission, owner_email: @user.email)
      @labware = Labware.create(material_submission: @material_submission, labware_index: 1, barcode: "AKER-1", print_count: 1, contents: {"1": { id: "#{@material_uuid}" } })
      @material_submission.labwares << @labware

      expect { delete :destroy, params: { id: @material_submission.id }}
      .to change(MaterialSubmission, :count).by(-1)
      .and change(Labware, :count).by(-1)
    end

  end
end
