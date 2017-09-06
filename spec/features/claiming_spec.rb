require 'rails_helper'

RSpec.feature "Claiming (Stamping)", type: :feature do

  # A Material Submission belongs to a User (person logged in during Submission process)
  # and a Contact (person selected as internal contact)
  # Here we want them to be the same person
  let(:user) { create(:user) }
  let(:contact) { create(:contact, email: user.email) }
  let(:stamps) { build_list(:stamp, 3) }

  before do
    sign_in(user)
    @material_submission = create(:claimable_material_submission, user: user, contact: contact)
    allow(StampClient::Stamp).to receive(:all).and_return(stamps)
    visit claim_submissions_path
  end

  describe 'On page load' do

    it 'displays the submission' do
      expect(page).to have_content(@material_submission.id)
    end

    it 'displays the stamps' do
      stamps.each do |stamp|
        expect(page).to have_content(stamp.name)
      end
    end

    it 'has a disabled submit button' do
      expect(page.find_button(disabled: true, value: "Stamp")).to be_disabled
    end

  end

  describe 'Submission selection', js: true do

    context 'when a Submission is selected' do

      before do
        page.check(name: "btSelectItem")
      end

      it 'enables the submit button' do
        expect(page.find_button(disabled: :all, value: "Stamp")).to_not be_disabled
      end

    end

  end

  describe 'Submitting the form', js: true do

    let(:submit_form) do
      page.check(name: "btSelectItem")
      click_button "Stamp"
    end

    context 'When ClaimService#process is successful' do

      before do
        allow_any_instance_of(ClaimService).to receive(:process).and_return(true)
      end

      it 'displays a success message' do
        submit_form
        expect(page).to have_content("Submission successfully claimed")
      end
    end

    context 'When ClaimService#process is unsuccessful' do

      before do
        allow_any_instance_of(ClaimService).to receive(:process).and_return(false)

        @error_message = "Something went wrong"
        allow_any_instance_of(ClaimService).to receive(:error).and_return(@error_message)
      end

      it 'displays an error message' do
        submit_form
        expect(page).to have_content(@error_message)
      end
    end

  end

end
