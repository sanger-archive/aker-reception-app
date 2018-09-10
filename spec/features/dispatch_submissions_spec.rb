require 'rails_helper'

RSpec.feature "DispatchSubmissions", type: :feature do

  before do
    login
  end

  describe '#index' do

    it 'displays the "Dispatch Labware" title' do
      visit material_submissions_dispatch_index_path
      expect(page).to have_text("Dispatch Labware")
    end

    it "gives some helpful text" do
      visit material_submissions_dispatch_index_path
      expect(page).to have_text("These customers are expecting labels or barcoded labware")
    end

    it 'shows a link to Previously Dispatched Submissions' do
      visit material_submissions_dispatch_index_path
      expect(page).to have_button("View Previously Dispatched Submissions")
    end

    context 'when there are no Submissions that need dispatching' do

      before do
        visit material_submissions_dispatch_index_path
      end

      it 'disables the Dispatch button' do
        expect(page.find('input[type="submit"]')).to be_disabled
      end

    end

    context 'when there are Submissions that need dispatching' do

      before do
        @active_material_submissions = create_list(:active_material_submission, 3)
        @printed_material_submissions = create_list(:printed_material_submission, 3)
        @dispatched_material_submissions = create_list(:dispatched_material_submission, 3)
        visit material_submissions_dispatch_index_path
      end

      it 'does not show Submissions have not been printed' do
        @active_material_submissions.each do |submission|
          expect(page.all('td', text: /^#{submission.id}$/)).to be_empty
        end
      end

      it 'displays Submissions that have not been dispatched' do
        @printed_material_submissions.each do |submission|
          expect(page.all('td', text: /^#{submission.id}$/).size).to eql(1)
        end
      end

      it 'does not show Submissions that have been dispatched' do
        @dispatched_material_submissions.each do |submission|
          expect(page.all('td', text: /^#{submission.id}$/)).to be_empty
        end
      end

      it 'does not disable the Print button' do
        expect(page.find('input[type="submit"]')).to_not be_disabled
      end

    end

  end

  describe '#update' do

    before do
      @printed_material_submissions = create_list(:printed_material_submission, 3)

      @submissions_to_dispatch = [@printed_material_submissions.first, @printed_material_submissions.last]
      visit material_submissions_dispatch_index_path
    end

    let(:dispatch_submissions) do
      @submissions_to_dispatch.each { |ss| page.check(option: ss.id) }
      click_button "Dispatch"
    end

    it 'dispatches those Submissions' do
      dispatch_submissions
      expect(page).to have_text "Submissions #{@printed_material_submissions.first.id}, #{@printed_material_submissions.last.id} dispatched."
    end

    it 'updates each Submission\'s "dispatched?" to true' do
      expect { dispatch_submissions }.to change { @submissions_to_dispatch.first.reload.dispatched? }.from(false).to(true)
        .and change { @submissions_to_dispatch.last.reload.dispatched? }.from(false).to(true)
    end

    context 'when no Submissions are selected' do
      let(:dispatch_with_no_submissions_selected) do
        click_button "Dispatch"
      end

      it 'shows an error' do
        dispatch_with_no_submissions_selected
        expect(page).to have_text('You must select at least one Submission to dispatch.')
      end
    end

  end
end
