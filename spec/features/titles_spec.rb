require 'rails_helper'
require 'jwt'

RSpec.describe 'Application', type: :feature do

  describe "title presence" do
    it "shows title on login page" do
      visit root_path
      expect(page).to have_title("Material Submission | Aker")
    end
  end

  # TODO:
  # these tests rely on redirect to login page, which is not yet ready
  describe "title ending" do
    before :each do
      let(:jwt) { JWT.encode({ data: { 'email' => 'user@here.com', 'groups' => ['world'] } }, Rails.configuration.jwt_secret_key, 'HS256') }
    end

    xit "appends '| Aker' to home page title" do
      visit root_path
      expect(page).to have_title(" | Aker")
    end

    xit "appends '| Aker' to material submission title" do
      visit material_submissions_path
      expect(page).to have_title(" | Aker")
    end

    xit "appends '| Aker' to completed submission title" do
      visit completed_submissions_path
      expect(page).to have_title(" | Aker")
    end
  end

end
