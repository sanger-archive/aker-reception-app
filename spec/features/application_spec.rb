require 'rails_helper'
require 'jwt'

RSpec.describe 'Application', type: :feature do

  describe 'login link' do

    context 'when sending a jwt' do
      let(:jwt) { JWT.encode({ data: { 'email' => 'other@here.com', 'groups' => %w[world team252] } }, Rails.configuration.jwt_secret_key, 'HS256') }

      before do
        # Somehow headers get HTTP_ prefixed onto them before they reach the controller. Shrugs.
        page.driver.header('X_AUTHORISATION', jwt)
      end

      it 'shows a logout link' do
        visit root_path
        expect(page).not_to have_content('Log in')
        expect(page).to have_content('Log out')
      end

      it "appends '| Aker' to material submission title" do
        visit material_submissions_path
        expect(page).to have_content("My Manifests")
      end

      it "appends '| Aker' to completed submission title" do
        visit material_submissions_print_index_path
        expect(page).to have_content("Dispatch Labware")
      end

      it "appends '| Aker' to material receptions title" do
        visit material_receptions_path
        expect(page).to have_content("Material Reception")
      end

    end
  end
end
