require 'rails_helper'

RSpec.describe MaterialSubmissionsController, type: :controller do

  describe "#destroy" do

    setup do
      @request.env['devise.mapping'] = Devise.mappings[:user]

      @user = FactoryGirl.create(:user)
      @labware_type = FactoryGirl.create :labware_type, {
        :num_of_cols => 1,
        :num_of_rows => 1
      }
      sign_in(@user)
    end


    it 'deletes the material submission and labwares' do
      @material_uuid = SecureRandom.uuid
      @material_submission = FactoryGirl.create(:material_submission, user: @user)
      @labware = Labware.create(material_submission: @material_submission, labware_index: 1, barcode: "AKER-1", print_count: 1, contents: {"1": { id: "#{@material_uuid}" } })
      @material_submission.labwares << @labware

      expect { delete :destroy, params: { id: @material_submission.id }}
      .to change(MaterialSubmission, :count).by(-1)
      .and change(Labware, :count).by(-1)
    end

  end
end
