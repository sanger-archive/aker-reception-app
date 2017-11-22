# encoding: utf-8
require 'cucumber/rspec/doubles'

Before do
  user = OpenStruct.new(email: 'other@sanger.ac.uk', groups: ['world'])
  @logged_in = false
  allow_any_instance_of(ApplicationController).to receive(:current_user) { @logged_in ? user : nil }
  allow_any_instance_of(ApplicationController).to receive(:jwt_provided?) { @logged_in }
  allow_any_instance_of(ApplicationController).to receive(:check_credentials).and_wrap_original { |m, *args| @logged_in || m.call(*args) }
end

Given(/^I have defined labware of type "([^"]*)"$/) do |arg1|
  LabwareType.create(
    name: 'ABgene AB_0800',
    description: '0.2ml full skirted clear/colourless 96 well plates (volume <100µl)',
    num_of_cols: 12,
    num_of_rows: 8,
    col_is_alpha: false,
    row_is_alpha: true
  )
end

Given(/^I have a material service running$/) do
  MatconClient::Material.stub(:schema).and_return(
    {
      "show_on_form" => [
        "scientific_name",
        "taxon_id",
        "gender",
        "donor_id",
        "phenotype",
        "supplier_name",
        "is_tumour",
        "tissue_type"
      ],
      "required" => [
        "taxon_id",
        "scientific_name",
        "gender",
        "donor_id",
        "supplier_name",
        "is_tumour",
        "tissue_type"
      ],
      "type" => "object",
      "properties" => {
        "taxon_id" => {
          "show_on_form" => true,
          "searchable" => true,
          "required" => true,
          "friendly_name" => "Tax id",
          "field_name_regex" => "^taxon[-_\\s]*(id)?$",
          "type" => "string"
        },

        "scientific_name" => {
          "show_on_form" => true,
          "searchable" => true,
          "required" => true,
          "friendly_name" => "Scientific name",
          "field_name_regex" => "^scientific[-_\\s]*(name)?$",
          "type" => "string"
        },
        "gender" => {
          "show_on_form" => true,
          "searchable" => true,
          "required" => true,
          "friendly_name" => "Gender",
          "field_name_regex" => "^(gender|sex)$",
          "allowed" => [
            "male",
            "female",
            "unknown",
            "not applicable",
            "mixed",
            "hermaphrodite"
          ],
          "type" => "string"
        },
        "donor_id" => {
          "show_on_form" => true,
          "searchable" => true,
          "required" => true,
          "friendly_name" => "Donor ID",
          "field_name_regex" => "^donor[-_\\s]*(id)?$",
          "type" => "string"
        },
        "phenotype" => {
          "show_on_form" => true,
          "searchable" => true,
          "required" => false,
          "friendly_name" => "Phenotype",
          "field_name_regex" => "^phenotype$",
          "type" => "string"
        },
        "supplier_name" => {
          "show_on_form" => true,
          "searchable" => true,
          "required" => true,
          "friendly_name" => "Supplier name",
          "field_name_regex" => "^supplier[-_\\s]*(name)?$",
          "type" => "string"
        },
        "is_tumour" => {
          "show_on_form" => true,
          "searchable" => true,
          "required" => true,
          "allowed" => [
            "tumour",
            "normal"
          ],
          "friendly_name" => "Tumour?",
          "field_name_regex" => "^(tumour|tumor)$",
          "type" => "string"
        },
        "tissue_type" => {
          "show_on_form" => true,
          "searchable" => true,
          "required" => true,
          "allowed" => [
            "dna/rna",
            "blood",
            "saliva",
            "tissue",
            "cells",
            "lysed cells"
          ],
          "friendly_name" => "Tissue Type",
          "field_name_regex" => "^tissue[-_\s]type$",
          "type" => "string"
        }
      }
    })
end

Given(/^I have the internal contact "([^"]*)"$/) do |arg1|
  Contact.create(fullname: arg1, email: arg1)
end

Given(/^the taxonomy service has the following taxonomies defined:$/) do |table|
  cached_taxonomies = {}
  table.hashes.each_with_index do |taxonomy, index|
    tax_info = double('taxonomy_info', { taxId: taxonomy['Taxon Id'], scientificName: taxonomy['Scientific Name']})
    cached_taxonomies[tax_info.taxId] = { taxId: tax_info.taxId, scientificName: tax_info.scientificName}
    allow(TaxonomyClient::Taxonomy).to receive(:find).with(tax_info.taxId).and_return(tax_info)
  end
  allow_any_instance_of(SubmissionsController).to receive(:cached_taxonomies).and_return(cached_taxonomies)
end

When(/^I should see a modal with the text "([^"]*)"$/) do |text|
  sleep 3
  step("I should see \"#{text}\"")
end

Given(/^I am logged in$/) do
  @logged_in = true
end

Given(/^I visit the homepage$/) do
  #visit('/')
  visit root_path
  step("I should see \"Material Submission\"")
end

Given(/^I click on "([^"]*)"$/) do |arg1|
  click_on(arg1)
end

Given(/^I check "([^"]*)"$/) do |arg1|
  check(arg1)
end

Given(/^I go to next screen$/) do
  within(first('form > .row > .col-md-12')) { click_on('Next') }
end

Then(/^I am in "([^"]*)"$/) do |arg1|
  expect(page).to have_content(arg1)
end

Given(/^I select a type of labware$/) do
  find("input[name=\"material_submission[labware_type_id]\"]").set(true)
end

Given(/^I want to create (\d+) labware$/) do |arg1|
  fill_in('How many plates or tubes', :with => arg1)
end

When(/^I upload the file "([^"]*)"$/) do |arg1|
  attach_file('Upload CSV', File.absolute_path(arg1), make_visible: true)
end

Given(/^I debug$/) do 
  binding.pry
end

Then(/^I should see data from my file like a textbox containing "([^"]*)"$/) do |arg1|
  expect(page).to have_selector("input[value='" + arg1 + "']")
end

Then(/^I should see data from my file like a dropdown with "([^"]*)" selected$/) do |arg1|
  expect(page).to have_selector("select[value='" + arg1 + "']")
end

Then(/^I should see validation errors$/) do
  expect(page).to have_content('validation')
end

Then(/^I should not see any validation errors$/) do
  expect(page).not_to have_content('validation')
end

When(/^I enter my details as collaborator$/) do
  fill_in('Address', with: 'Some address')
end

Then(/^show me the page$/) do
  save_and_open_page
end

When(/^I select "([^"]*)" from the "([^"]*)" select$/) do |option, dropdown|
  select(option, from: dropdown)
end

Then(/^I should see "([^"]*)"$/) do |arg1|
  expect(page).to have_content(arg1)
end

Then(/^I know my shared submission identifier$/) do
  last_id = MaterialSubmission.last.id.to_s
  expect(page).to have_content("Submission "+last_id)
end

# Find a select box by (label) name or id and assert the given text is selected
Then(/^"([^"]*)" should be selected for "([^"]*)"$/) do |selected_text, dropdown|
  expect(page).to have_select(dropdown, selected: selected_text)
end

# Find a select box by (label) name or id and assert the expected option is present
Then(/^"([^"]*)" should contain "([^"]*)"$/) do |dropdown, text|
  expect(page).to have_select(dropdown, with_options: [text])
end

# Find the table by name or id and assert the given amount of rows are present in it's body
Then(/^"([^"]*)" should contain (\d+) rows$/) do |table, rows|
  page.all('table#' + table + ' tbody tr').count.should == rows
end
