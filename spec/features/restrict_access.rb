require 'rails_helper'
require 'ostruct'

RSpec.feature "RestrictAccess", type: :feature do

  describe "when accessing restriced pages" do
    before do
      allow_any_instance_of(JWTCredentials).to receive(:check_credentials)
      allow_any_instance_of(JWTCredentials).to receive(:current_user).and_return(user)
    end

    context 'as an SSR' do
      let(:user) { OpenStruct.new(email: 'ssr@sanger.ac.uk', groups: ['team252']) }

      it 'allows access to the dispatch page' do
        visit completed_submissions_path
        expect(page).to_not have_content("Permission Denied")
      end

      it 'allows access to the material receiption page' do
        visit material_receptions_path
        expect(page).to_not have_content("Permission Denied")
      end
    end

    context 'as someone who is not an SSR' do
      let(:user) { OpenStruct.new(email: 'user@sanger.ac.uk', groups: ['world']) }

      it 'denies access to the dispatch page' do
        visit completed_submissions_path
        expect(page).to have_content("Permission Denied")
      end

      it 'denies access to the material receiption page' do
        visit material_receptions_path
        expect(page).to have_content("Permission Denied")
      end
    end
  end

end
