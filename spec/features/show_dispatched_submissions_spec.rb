require 'rails_helper'

RSpec.feature "ShowDispatchedSubmissions", type: :feature, js: true do

  before do
    login
  end

  let(:visit_dispatched_submissions) do
    visit material_submissions_dispatch_index_path
    click_button "View Previously Dispatched Submissions"
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

    context 'when there are previously dispatched Submissions' do

      before do
        @dispatched_material_submissions = create_list(:dispatched_material_submission, 3)
        visit_dispatched_submissions
      end

      it 'displays Submissions that have been dispatched' do
        @dispatched_material_submissions.each do |submission|
          expect(page.all('td', text: /^#{submission.id}$/).size).to eql(1)
        end
      end

    end
  end
end
