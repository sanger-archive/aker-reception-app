require 'rails_helper'

RSpec.feature "ShowPrintedManifests", type: :feature, js: true do

  before do
    login
  end

  let!(:printed_manifests) { create_list(:printed_manifest, 3) }

  let(:visit_printed_manifests) do
    visit manifests_print_index_path
    click_button "View Previously Printed Manifests"
  end

  describe '#index' do

    before do
      visit_printed_manifests
    end

    it 'displays the "Dispatch Labware" title' do
      expect(page).to have_text("Dispatch Labware")
    end

    it 'displays some helpful text' do
      expect(page).to have_text("These Manifests have had labels printed", wait: 5)
    end

    context 'when there are previously printed Manifests' do

      it 'displays Manifests that have been printed' do
        printed_manifests.each do |manifest|
          expect(page).to have_css('td', text: manifest.id)
        end
      end

    end
  end
end
