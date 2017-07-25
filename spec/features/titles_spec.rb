require 'rails_helper'

RSpec.describe 'Application', type: :feature do
  describe "title presence" do
    it "shows title on login page" do
      visit root_path
      expect(page).to have_title("Material Submission | Aker")
    end
  end

  describe "title ending" do
    before :each do
      sign_in(create(:user))
    end

    it "appends '| Aker' to home page title" do
      visit root_path
      expect(page).to have_title(" | Aker")
    end

    it "appends '| Aker' to material submission title" do
      visit material_submissions_path
      expect(page).to have_title(" | Aker")
    end

    it "appends '| Aker' to completed submission title" do
      visit completed_submissions_path
      expect(page).to have_title(" | Aker")
    end
  end

end
