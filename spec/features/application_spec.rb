require 'rails_helper'
require 'jwt'

RSpec.describe 'Application', type: :feature do

  describe 'login link' do
    context 'when not sending a jwt' do
      it 'shows a login link' do
        visit root_path
        expect(page).to have_content('Log in')
        expect(page).not_to have_content('Log out')
      end
    end

    context 'when sending a jwt' do
      let(:jwt) { JWT.encode({ data: { 'email' => 'other@here.com', 'groups' => ['world'] } }, Rails.configuration.jwt_secret_key, 'HS256') }

      it 'shows a logout link' do
        # Somehow headers get HTTP_ prefixed onto them before they reach the controller. Shrugs.
        page.driver.header('X_AUTHORISATION', jwt)
        visit root_path

        expect(page).not_to have_content('Log in')
        expect(page).to have_content('Log out')
      end
    end
  end
end
