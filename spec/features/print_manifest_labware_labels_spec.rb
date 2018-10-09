require 'rails_helper'

RSpec.feature "PrintManifestLabwareLabels", type: :feature do

  before do
    login
  end

  describe '#index' do

    it 'displays the "Dispatch Labware" title' do
      visit manifests_print_index_path
      expect(page).to have_text("Dispatch Labware")
    end

    it "gives some helpful text" do
      visit manifests_print_index_path
      expect(page).to have_text("These Manifests need labels printing")
    end

    it 'shows a button "Show Previously Printed Manifests"' do
      visit manifests_print_index_path
      expect(page).to have_button("View Previously Printed Manifests")
    end

    context 'when there are no Manifests that need printing' do

      before do
        visit manifests_print_index_path
      end

      it 'disables the Print button' do
        expect(page.find('input[type="submit"]')).to be_disabled
      end

    end

    context 'when there are Manifests that need printing' do

      before do
        @active_manifests = create_list(:active_manifest, 3)
        @printed_manifests = create_list(:printed_manifest, 3)
        visit manifests_print_index_path
      end

      it 'displays Manifests that have not been printed' do
        @active_manifests.each do |submission|
          expect(page.all('td', text: /^#{submission.id}$/).size).to eql(1)
        end
      end

      it 'does not show Manifests that have been printed' do
        @printed_manifests.each do |submission|
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
      @active_manifests = create_list(:active_manifest, 3)
      @active_manifests.each { |ams| ams.update_attributes(no_of_labwares_required: 1) }

      @manifests_to_print = [@active_manifests.first, @active_manifests.last]
      visit manifests_print_index_path
    end

    let(:print_manifests) do
      @manifests_to_print.each { |ss| page.check(option: ss.id) }
      select @printers.first.name, from: 'printer[name]'
      click_button "Print"
    end

    it 'prints those Manifests' do
      print_manifests
      expect(page).to have_text "Labels for labware from Manifests #{@manifests_to_print.first.id}, "\
        "#{@manifests_to_print.second.id} sent to #{@printers.first.name}."
    end

    it 'updates each Manifest\'s status to "printed"' do
      expect { print_manifests }.to change { @manifests_to_print.first.reload.status }.from('active').to('printed')
        .and change { @manifests_to_print.last.reload.status }.from('active').to('printed')
    end

    it 'increments each Manifest\'s Labware\'s print count' do
      labwares = [
        @active_manifests.first.labwares,
        @active_manifests.second.labwares,
        @active_manifests.third.labwares
      ].flatten

      expect { print_manifests }.to change { labwares.first.reload.print_count }.by(1)
        .and change { labwares.second.reload.print_count }.by(0) # Labware not in @manifests_to_print
        .and change { labwares.third.reload.print_count }.by(1)
    end

    context 'when no Manifests are selected' do
      let(:print_with_no_manifests_selected) do
        click_button "Print"
      end

      it 'shows an error' do
        print_with_no_manifests_selected
        expect(page).to have_text('You must select at least one Manifest to print.')
      end
    end
  end
end
