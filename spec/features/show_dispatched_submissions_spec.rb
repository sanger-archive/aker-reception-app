require 'rails_helper'

RSpec.feature "ShowDispatchedSubmissions", type: :feature do

  before do
    login
  end

  let(:visit_dispatched_submissions) do
    visit material_submissions_dispatch_index_path
    click_link "Previously Dispatched Submissions"
  end

  describe '#index' do

    it 'displays the "Dispatch Labware" title' do
      visit_dispatched_submissions
      expect(page).to have_text("Dispatch Labware")
    end

    it 'displays some helpful text' do
      visit_dispatched_submissions
      expect(page).to have_text("These Submissions have been dispatched")
    end

    it 'does not show a link to Previously Dispatched Submissions' do
      visit_dispatched_submissions
      expect(page).not_to have_link("Previously Dispatched Submissions")
    end

    it 'shows a "Back" button' do
      visit_dispatched_submissions
      expect(page).to have_link("Back")
    end

    context 'when there are previously dispatched Submissions' do

      before do
        @active_material_submissions = create_list(:active_material_submission, 3)
        @printed_material_submissions = create_list(:printed_material_submission, 3)
        @dispatched_material_submissions = create_list(:dispatched_material_submission, 3)
        visit_dispatched_submissions
      end

      it 'displays Submissions that have been dispatched' do
        @dispatched_material_submissions.each do |submission|
          expect(page.all('td', text: /^#{submission.id}$/).size).to eql(1)
        end
      end

      it 'does not show Submissions that have not been dispatched' do
        @active_material_submissions.each do |submission|
          expect(page.all('td', text: /^#{submission.id}$/)).to be_empty
        end

        @printed_material_submissions.each do |submission|
          expect(page.all('td', text: /^#{submission.id}$/)).to be_empty
        end
      end

      it 'does not show the Dispatch button' do
        expect(page.all('input[type="submit"]')).to be_empty
      end

    end
  end
end
