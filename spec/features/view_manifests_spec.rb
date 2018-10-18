require 'rails_helper'

RSpec.feature "View Manifests", type: :feature do

  let(:manifest) { create(:active_manifest) }

  before do
    login
    visit manifest_path(manifest)
  end

  it 'displays a title of "Manifest :id"' do
    expect(page).to have_text("Manifest #{manifest.id}")
  end

end
