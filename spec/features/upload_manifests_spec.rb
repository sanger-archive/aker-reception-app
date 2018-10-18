require 'rails_helper'
require 'webmock/rspec'


RSpec.shared_examples "displays an error" do |errorMessage|

  it 'displays an error' do
    expect(page.find('#page-error-alert')).to have_text(errorMessage)
  end

end


RSpec.feature "Upload Manifests", type: :feature, js: true do

  include StubHelper


  let(:number_of_containers_required) { 3 }

  let(:upload_manifest) do
    login
    visit new_manifest_path
    choose @rack.name
    fill_in 'manifest[no_of_labwares_required]', with: number_of_containers_required
    click_button 'Next'
    sleep 1 # Sadly needed right now (I think Capybara tries to attach the file before DOM is ready, and so input[file] onChange event not fired)
    attach_file 'manifest_upload', file_fixture(manifest_file).realpath, make_visible: true
  end

  before :each do

    stub_matcon_client_schema
    allow(TaxonomyClient::Taxonomy).to receive(:find).and_return(double(taxId: '3', scientificName: 'Something Latiny'))
    @rack = create(:rack_labware_type)
    upload_manifest
  end

  context 'when uploading a Manifest with duplicate Plate IDs' do
    let(:manifest_file) { 'duplicate_plate_ids.xlsx' }
    include_examples "displays an error", 'Duplicate entry found for plate_2: Position A:1'
  end

  context 'when uploading a Manifest with fewer plates than Labwares required' do
    let(:manifest_file) { 'too_few_plates.xlsx' }
    include_examples 'displays an error', 'Expected 3 labwares in Manifest but could only find 1.'
  end

  context 'when uploading a Manifest with more plates than Labwares required' do
    let(:manifest_file) { 'too_many_plates.xlsx' }
    include_examples 'displays an error', 'Expected 3 labwares in Manifest but found 4.'
  end

  context 'when uploading a Manifest with distinct Plate IDs' do
    let(:manifest_file) { 'good_manifest_with_3_plates.csv' }

    it 'shows the a Supplier Plate Name as the title for each tab' do
      expect(page.all('ul.nav.nav-tabs a', text: 'plate_1').size).to eql 1
      expect(page.all('ul.nav.nav-tabs a', text: 'plate_2').size).to eql 1
      expect(page.all('ul.nav.nav-tabs a', text: 'plate_3').size).to eql 1
    end

    it 'fills each table with information from the Manifest' do
      expect(page.find('div.tab-content table')).to have_selector("input[value='supplier name 1']")
      expect(page.find('div.tab-content table')).to have_selector("input[value='donor id 1']")
      expect(page.find('div.tab-content table')).to have_selector("input[value='Red']")

      click_link 'plate_2'

      expect(page.find('div.tab-content table')).to have_selector("input[value='supplier name 2']")
      expect(page.find('div.tab-content table')).to have_selector("input[value='donor id 2']")
      expect(page.find('div.tab-content table')).to have_selector("input[value='Green']")

      click_link 'plate_3'

      expect(page.find('div.tab-content table')).to have_selector("input[value='supplier name 3']")
      expect(page.find('div.tab-content table')).to have_selector("input[value='donor id 3']")
      expect(page.find('div.tab-content table')).to have_selector("input[value='Yellow']")
    end

    it 'does not display any error if the contents are right' do
      expect(first("td[data-psd-schema-validation-name=taxon_id]")).to have_css('.has-success')
      expect(first("td[data-psd-schema-validation-name=scientific_name]")).to have_css('.has-success')
      expect(first("ul.nav.nav-tabs")).not_to have_css('.bg-danger')
    end

  end

  context 'when uploading a valid Manifest with no Plate ID column' do
    let(:manifest_file) { 'simple_manifest.csv' }

    xit 'populates the current tab' do
      expect(page.find('div.tab-content table')).to have_selector("input[value='78placebo-501']")
      expect(page.find('div.tab-content table')).to have_selector("input[value='78placebo-502']")
      expect(page.find('div.tab-content table')).to have_selector("input[value='78placebo-503']")
      expect(page.find('div.tab-content table')).to have_selector("input[value='6']")
    end
  end

end
