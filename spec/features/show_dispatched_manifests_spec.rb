require 'rails_helper'

RSpec.feature "ShowDispatchedManifests", type: :feature, js: true do

  before do
    login
  end

  let(:visit_dispatched_manifests) do
    visit manifests_dispatch_index_path
    click_button "View Previously Dispatched Manifests"
  end

  describe '#index' do

    it 'displays the "Dispatch Labware" title' do
      visit_dispatched_manifests
      expect(page).to have_text("Dispatch Labware")
    end

    it 'displays some helpful text' do
      visit_dispatched_manifests
      expect(page).to have_text("These Manifests have been dispatched")
    end

    context 'when there are previously dispatched Manifests' do

      before do
        @dispatched_manifests = create_list(:dispatched_manifest, 3)
        visit_dispatched_manifests
      end

      it 'displays Manifests that have been dispatched' do
        @dispatched_manifests.each do |manfiest|
          expect(page.all('td', text: /^#{manfiest.id}$/).size).to eql(1)
        end
      end

    end
  end
end
