@javascript

Feature: Create a submission

Because I am a collaborator working remotely
And I want to send samples to an internal contact at the institute
I want to to provide all the needed information required for my contact

Background:

Given I have defined labware of type "ABgene AB_0800"
And I have the internal contact "test@test"
And I am logged in
And I have a material service running

Scenario:

Given I visit the homepage

And I click on "Create New Submission"

Then I am in "Container Type"

Given I select a type of labware
And I want to create 1 labware
And I click on "Next"

Then I am in "Biomaterial Metadata"

Given I upload the file "test/data/correct_manifest.csv"
Then I should see data from my file like a textbox containing "334457"
And I should see data from my file like a dropdown with "male" selected
And I should see data from my file like a dropdown with "Homo sapiens" selected

When I go to next screen
Then I should not see any validation errors

And I am in "Ethics"

When I check "I confirm that no HMDMC is required"
And I click on "Next"

Then I am in "Delivery Details"

Given I enter my details as collaborator
When I select "test@test" from the "Sanger Sample Custodian" select

Then I know my shared submission identifier
