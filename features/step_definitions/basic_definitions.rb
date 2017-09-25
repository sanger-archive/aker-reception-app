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
      'required' => ['REQUIRED_FREE', 'REQUIRED_ENUM', 'scientific_name'],
      'properties' => {
        'scientific_name' => {
          'required' => true
        },
        'OPTIONAL' => {
          'required' => false,
        },
        'REQUIRED_FREE' => {
          'required' => true,
        },
        'REQUIRED_ENUM' => {
          'required' => true,
          'allowed' => ['ALPHA', 'BETA', 'GAMMA'],
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
  visit('/')
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
  execute_script("$('input.upload-button').show()")
  attach_file('Upload CSV', File.absolute_path(arg1))
end

Then(/^I should display the data of my file$/) do
  page.has_content?("3344556677")
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

When(/^I select the contact "([^"]*)"$/) do |arg1|
  select(arg1, :from => 'Sanger Sample Custodian')
end

Then(/^I should see "([^"]*)"$/) do |arg1|
  expect(page.has_content?(arg1)).to eq(true)
end

Then(/^I know my shared submission identifier$/) do
  last_id = MaterialSubmission.last.id.to_s
  expect(page.has_content?("Submission "+last_id)).to eq(true)
end