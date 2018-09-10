require 'rails_helper'

RSpec.feature "PrintSubmissionLabwareLabels", type: :feature do

  before do
    login
  end

  describe '#index' do

    it 'displays the "Dispatch Labware" title' do
      visit material_submissions_print_index_path
      expect(page).to have_text("Dispatch Labware")
    end

    it "gives some helpful text" do
      visit material_submissions_print_index_path
      expect(page).to have_text("These Submissions need labels printing")
    end

    it 'shows a button "Show Previously Printed Submissions"' do
      visit material_submissions_print_index_path
      expect(page).to have_button("View Previously Printed Submissions")
    end

    context 'when there are no Submissions that need printing' do

      before do
        visit material_submissions_print_index_path
      end

      it 'disables the Print button' do
        expect(page.find('input[type="submit"]')).to be_disabled
      end

    end

    context 'when there are Submissions that need printing' do

      before do
        @active_material_submissions = create_list(:active_material_submission, 3)
        @printed_material_submissions = create_list(:printed_material_submission, 3)
        visit material_submissions_print_index_path
      end

      it 'displays Submissions that have not been printed' do
        @active_material_submissions.each do |submission|
          expect(page.all('td', text: /^#{submission.id}$/).size).to eql(1)
        end
      end

      it 'does not show Submissions that have been printed' do
        @printed_material_submissions.each do |submission|
          expect(page.all('td', text: /^#{submission.id}$/)).to be_empty
        end
      end

      it 'does not disable the Print button' do
        expect(page.find('input[type="submit"]')).to_not be_disabled
      end

    end

  end

  describe '#post' do

    before do
      @printers = create_list(:printer, 5)
      @active_material_submissions = create_list(:active_material_submission, 3)
      @active_material_submissions.each { |ams| ams.update_attributes(no_of_labwares_required: 1) }

      @submissions_to_print = [@active_material_submissions.first, @active_material_submissions.last]
      visit material_submissions_print_index_path
    end

    let(:print_submissions) do
      @submissions_to_print.each { |ss| page.check(option: ss.id) }
      click_button "Print"
    end

    it 'prints those Submissions' do
      print_submissions
      expect(page).to have_text "Labels for labware from Submissions #{@submissions_to_print.first.id}, "\
        "#{@submissions_to_print.second.id} sent to #{@printers.first.name}."
    end

    it 'updates each Submission\'s status to "printed"' do
      expect { print_submissions }.to change { @submissions_to_print.first.reload.status }.from('active').to('printed')
        .and change { @submissions_to_print.last.reload.status }.from('active').to('printed')
    end

    it 'increments each Submission\'s Labware\'s print count' do
      labwares = [
        @active_material_submissions.first.labwares,
        @active_material_submissions.second.labwares,
        @active_material_submissions.third.labwares
      ].flatten

      expect { print_submissions }.to change { labwares.first.reload.print_count }.by(1)
        .and change { labwares.second.reload.print_count }.by(0) # Labware not in @submissions_to_print
        .and change { labwares.third.reload.print_count }.by(1)
    end

    context 'when no Submissions are selected' do
      let(:print_with_no_submissions_selected) do
        click_button "Print"
      end

      it 'shows an error' do
        print_with_no_submissions_selected
        expect(page).to have_text('You must select at least one Submission to print.')
      end
    end
  end
end
