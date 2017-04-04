require 'rails_helper'

RSpec.describe Users::SessionsController, type: :controller do

  describe "#create" do

    it 'authenticates with ldap' do
      @request.env['devise.mapping'] = Devise.mappings[:user]

      groups = ["cowboys"]

      user = create(:user)
      expect(user).to receive(:fetch_groups).and_return(groups)
      allow(request.env['warden']).to receive(:authenticate!).and_return(user)
      allow(controller).to receive(:current_user).and_return(user)
      post :create, params: { user: { email: "jeff", password: 'abc123' } }
      expect(response).to redirect_to(root_url)
      userinfo = session["user"]

      expect(userinfo["user"]["email"]).to eq user.email
      expect(userinfo["groups"]).to eq groups
    end

  end
end
