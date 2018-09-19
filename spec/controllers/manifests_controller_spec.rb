require 'rails_helper'
require 'ostruct'

RSpec.describe ManifestsController, type: :controller do
  it_behaves_like 'service that validates credentials', [:index]

  describe "#index" do
    context 'when no JWT is included' do
      let(:expected_redirect) { Rails.configuration.login_url+'?'+{redirect_url: request.original_url}.to_query }

      it 'redirects to the login page' do
        get :index
        expect(response).to redirect_to(expected_redirect)
      end
    end

    context 'when JWT is included' do
      before do
        user = OpenStruct.new(email: 'other@sanger.ac.uk', groups: ['world'])
        allow(controller).to receive(:check_credentials)
        allow(controller).to receive(:current_user).and_return(user)

        sub1 = build(:manifest, status: 'labware', owner_email: user.email)
        sub2 = build(:manifest, status: 'dispatch', owner_email: user.email)
        sub3 = build(:manifest, status: 'ACTIVE', owner_email: user.email)

        controller.instance_variable_set(:@pending_manifests, [sub1,sub2])
        controller.instance_variable_set(:@active_manifests, [sub3])
      end

      it 'has a list of incompleted manifests' do
        incompleted_manifests = controller.instance_variable_get("@pending_manifests")
        expect(incompleted_manifests.length).to eq 2
      end

      it 'has a list of completed manifests' do
        completed_manifests = controller.instance_variable_get("@active_manifests")
        expect(completed_manifests.length).to eq 1
      end
    end
  end

  describe "#destroy" do

    setup do
      @user = OpenStruct.new(email: 'other@sanger.ac.uk', groups: ['world'])
      allow(controller).to receive(:check_credentials)
      allow(controller).to receive(:current_user).and_return(@user)

      @labware_type = FactoryBot.create :labware_type, {
        :num_of_cols => 1,
        :num_of_rows => 1
      }
    end

    it 'deletes the manifest and labwares' do
      @material_uuid = SecureRandom.uuid
      @manifest = FactoryBot.create(:manifest, owner_email: @user.email)
      @labware = Labware.create(manifest: @manifest, labware_index: 1, barcode: "AKER-1", print_count: 1, contents: {"1": { id: "#{@material_uuid}" } })
      @manifest.labwares << @labware

      expect { delete :destroy, params: { id: @manifest.id }}
      .to change(Manifest, :count).by(-1)
      .and change(Labware, :count).by(-1)
    end

  end
end
