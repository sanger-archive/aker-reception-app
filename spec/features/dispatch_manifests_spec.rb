require 'rails_helper'

RSpec.feature "DispatchManifests", type: :feature do

  before do
    login
  end

  describe '#index' do

    it 'displays the "Dispatch Labware" title' do
      visit manifests_dispatch_index_path
      expect(page).to have_text("Dispatch Labware")
    end

    it "gives some helpful text" do
      visit manifests_dispatch_index_path
      expect(page).to have_text("These customers are expecting labels or barcoded labware")
    end

    it 'shows a link to Previously Dispatched Manifests' do
      visit manifests_dispatch_index_path
      expect(page).to have_button("View Previously Dispatched Manifests")
    end

    context 'when there are no Manifests that need dispatching' do

      before do
        visit manifests_dispatch_index_path
      end

      it 'disables the Dispatch button' do
        expect(page.find('input[type="submit"]')).to be_disabled
      end

    end

    context 'when there are Manifests that need dispatching' do

      before do
        @active_manifests = create_list(:active_manifest, 3)
        @printed_manifests = create_list(:printed_manifest, 3)
        @dispatched_manifests = create_list(:dispatched_manifest, 3)
        visit manifests_dispatch_index_path
      end

      it 'does not show Manifests have not been printed' do
        @active_manifests.each do |submission|
          expect(page.all('td', text: /^#{submission.id}$/)).to be_empty
        end
      end

      it 'displays Manifests that have not been dispatched' do
        @printed_manifests.each do |submission|
          expect(page.all('td', text: /^#{submission.id}$/).size).to eql(1)
        end
      end

      it 'does not show Manifests that have been dispatched' do
        @dispatched_manifests.each do |submission|
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
      @printed_manifests = create_list(:printed_manifest, 3)

      @submissions_to_dispatch = [@printed_manifests.first, @printed_manifests.last]
      visit manifests_dispatch_index_path
    end

    let(:dispatch_submissions) do
      @submissions_to_dispatch.each { |ss| page.check(option: ss.id) }
      click_button "Dispatch"
    end

    it 'dispatches those Manifests' do
      dispatch_submissions
      expect(page).to have_text "Manifests #{@printed_manifests.first.id}, #{@printed_manifests.last.id} dispatched."
    end

    it 'updates each Manifest\'s "dispatched?" to true' do
      expect { dispatch_submissions }.to change { @submissions_to_dispatch.first.reload.dispatched? }.from(false).to(true)
        .and change { @submissions_to_dispatch.last.reload.dispatched? }.from(false).to(true)
    end

    context 'when no Manifests are selected' do
      let(:dispatch_with_no_submissions_selected) do
        click_button "Dispatch"
      end

      it 'shows an error' do
        dispatch_with_no_submissions_selected
        expect(page).to have_text('You must select at least one Manifest to dispatch.')
      end
    end

  end
end
