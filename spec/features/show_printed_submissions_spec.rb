require 'rails_helper'

RSpec.feature "ShowPrintedSubmissions", type: :feature do

  before do
    login
  end

  let(:visit_printed_submissions) do
    visit material_submissions_print_index_path
    click_link "Previously Printed Submissions"
  end

  describe '#index' do

    it 'displays the "Dispatch Labware" title' do
      visit_printed_submissions
      expect(page).to have_text("Dispatch Labware")
    end

    it 'displays some helpful text' do
      visit_printed_submissions
      expect(page).to have_text("These Submissions have had labels printed")
    end

    it 'does not show a link to Previously Printed Submissions' do
      visit_printed_submissions
      expect(page).not_to have_link("Previously Printed Submissions")
    end

    context 'when there are previously printed Submissions' do

      before do
        @active_material_submissions = create_list(:active_material_submission, 3)
        @printed_material_submissions = create_list(:printed_material_submission, 3)
        visit_printed_submissions
      end

      it 'displays Submissions that have been printed' do
        @printed_material_submissions.each do |submission|
          expect(page.all('td', text: /^#{submission.id}$/).size).to eql(1)
        end
      end

      it 'does not show Submissions that have been printed' do
        @active_material_submissions.each do |submission|
          expect(page.all('td', text: /^#{submission.id}$/)).to be_empty
        end
      end

    end
  end
end
