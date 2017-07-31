@javascript

Feature: Create a submission

Because I am a collaborator working remotely
And I want to send samples to an internal contact at the institute
I want to to provide all the needed information required for my contact

Background:

Given I have defined labware of type "ABgene AB_0800"
And I have the internal contact "test@test"
And I am logged in

Scenario:

Given I visit the homepage

And I click on "Create New Submission"

Then I am in "Container Type"

Given I select a type of labware
And I want to create 1 labware
And I click on "Next"

Then I am in "Biomaterial Provenance"

Given I upload the file "test/data/manifest.csv"
Then I should display the data of my file
When I go to next screen
Then I should not see any validation errors
And I am in "Ethics"

When I check "I confirm that no HMDMC is required"
And I click on "Next"

Then I am in "Delivery Details"

Given I enter my details as collaborator
And I select the contact "test@test"

Then I know my shared submission identifier
