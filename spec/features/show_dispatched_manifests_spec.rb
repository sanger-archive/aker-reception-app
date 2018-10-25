require 'rails_helper'

RSpec.feature "ShowDispatchedManifests", type: :feature, js: true do

  before do
    login
  end

  let!(:dispatched_manifests) { create_list(:dispatched_manifest, 3) }

  let(:visit_dispatched_manifests) do
    visit manifests_dispatch_index_path
    click_button "View Previously Dispatched Manifests"
  end

  describe '#index' do

    before(:each) do
      visit_dispatched_manifests
    end

    it 'displays the "Dispatch Labware" title' do
      expect(page).to have_text("Dispatch Labware")
    end

    context 'when there are previously dispatched Manifests' do

      it 'displays Manifests that have been dispatched' do
        dispatched_manifests.each do |manifest|
          expect(page).to have_css('td', text: manifest.id)
        end
      end

    end
  end
end
