# encoding: utf-8
require 'cucumber/rspec/doubles'

Before do
  user = OpenStruct.new(:email => 'other@sanger.ac.uk', :groups => ['world'])
  MaterialSubmissionsController.any_instance.stub(:current_user).and_return(user)
  SubmissionsController.any_instance.stub(:current_user).and_return(user)
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
  MatconClient::Material.stub(:schema).and_return({
      'required' => ['supplier_name', 'scientific_name', 'gender', 'donor_id', 'phenotype'],
      'properties' => {
        'supplier_name' => {
          'required' => true,
          'friendly_name' => "Supplier name",
          'field_name_regex' => "^supplier[-_\s]*(name)?$",
        },
        'scientific_name' => {
          'required' => true,
          'field_name_regex' => "^scientific[-_\s]*(name)?$",
          'allowed' => ['Homo sapiens', 'Mus musculus'],
          'friendly_name' => "Scientific name"
        },
        'OPTIONAL' => {
          'required' => false,
        },
        'gender' => {
          'required' => true,
          'field_name_regex' => "^(gender|sex)$",
          'friendly_name' => "Gender"
        },
        'donor_id' => {
          'required' => true,
          'field_name_regex' => "^donor[-_\s]*(id)?$",
          'friendly_name' => "Donor ID"
        },
        'phenotype' => {
          'required' => true,
          'field_name_regex' => "^phenotype$",
          'friendly_name' => "Phenotype"
        }
      },
    })
end

Given(/^I have the internal contact "([^"]*)"$/) do |arg1|
  Contact.create(fullname: arg1, email: arg1)
end

Given(/^I am logged in$/) do
  visit root_path
end

Given(/^I visit the homepage$/) do
  #visit('/')
  visit root_path
end

Given(/^I click on "([^"]*)"$/) do |arg1|
  click_on(arg1)
end

Given(/^I check "([^"]*)"$/) do |arg1|
  check(arg1)
end

Given(/^I go to next screen$/) do
  first('a.save').trigger('click')
end

Then(/^I am in "([^"]*)"$/) do |arg1|
  expect(page.has_content?(arg1)).to eq(true)
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

Then(/^I should see data from my file like "([^"]*)"$/) do |arg1|
  expect(page).to have_selector("input[value='" + arg1 + "']")
end

Then(/^I should see validation errors$/) do
  expect(page.has_content?('validation')).to eq(true)
end

Then(/^I should not see any validation errors$/) do
  expect(page.has_content?('validation')).to eq(false)
end

When(/^I enter my details as collaborator$/) do
  fill_in('Address', :with => 'Some address')
end

Then(/^show me the page$/) do
  save_and_open_page
end

When(/^I select "([^"]*)" from the "([^"]*)" select$/) do |option, dropdown|
  select(option, from: dropdown)
end

Then(/^I should see "([^"]*)"$/) do |arg1|
  expect(page.has_content?(arg1)).to eq(true)
end

Then(/^I know my shared submission identifier$/) do
  last_id = MaterialSubmission.last.id.to_s
  expect(page.has_content?("Submission "+last_id)).to eq(true)
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
