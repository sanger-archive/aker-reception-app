require 'rails_helper'

RSpec.feature "Sessions", type: :feature do

  describe 'Navigating to the homepage' do
    context 'when I am not logged in' do
      it 'will redirect me to the login page' do
        visit root_path
        expect(page).to have_current_path(new_user_session_path)
      end
    end

    context 'when I am logged in' do
      before :each do
        sign_in(create(:user))
      end

      it 'will take me to the homepage' do

        visit root_path
        expect(page).to have_current_path(root_path)
      end
    end

  end

end
