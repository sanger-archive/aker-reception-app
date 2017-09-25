require 'rails_helper'
require 'ostruct'

RSpec.describe MaterialSubmissionsController, type: :controller do

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
