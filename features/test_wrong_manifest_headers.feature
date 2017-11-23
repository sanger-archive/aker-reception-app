@javascript

Feature: Test manifest CSV file with unrecognised headers

Because I am a collaborator working remotely
And I want to send samples to an internal contact at the institute
I want to to provide all the needed information required for my contact

Background:

Given I have defined labware of type "ABgene AB_0800"
And I have the internal contact "test@test"
And I am logged in
And I have a material service running
And the taxonomy service has the following taxonomies defined:

| Taxon Id | Scientific Name       |
| 9606     | Homo sapiens          |
| 1234     | One specie            |
| 4567     | Another different one |


Scenario:

Given I visit the homepage
Then I click on "Create New Submission"

Then I am in "Container Type"

Given I select a type of labware
And I want to create 1 labware
And I click on "Next"

Then I am in "Biomaterial Metadata"

Given I upload the file "test/data/incorrect_headers_manifest.csv"
Then I should see a modal with the text "Select CSV mappings"
Then "form-fields" should contain "Taxon Id (taxon_id)"
Then "form-fields" should contain "Position (position)"
Then "form-fields" should contain "Scientific name (scientific_name)"
Then "form-fields" should contain "Supplier name (supplier_name)"
Then "form-fields" should contain "Gender (gender)"
Then "form-fields" should contain "Donor ID (donor_id)"
Then "form-fields" should contain "Phenotype (phenotype)"
Then "form-fields" should contain "*Tumour? (is_tumour)"
Then "form-fields" should contain "*Tissue Type (tissue_type)"


Then "fields-from-csv" should contain "tax_id"
Then "fields-from-csv" should contain "Well Positio"
Then "fields-from-csv" should contain "sciname"
Then "fields-from-csv" should contain "Dono"
Then "fields-from-csv" should contain "ender"
Then "fields-from-csv" should contain "supname"
Then "fields-from-csv" should contain "Phenotyp"
Then "fields-from-csv" should contain "Tissue"
Then "fields-from-csv" should contain "cancer"

Then "matched-fields-table" should contain 0 rows

When I select "*Taxon Id (taxon_id)" from the "form-fields" select
Then "*Taxon Id (taxon_id)" should be selected for "form-fields"

When I select "tax_id" from the "fields-from-csv" select
Then "tax_id" should be selected for "fields-from-csv"

Given I click on "match-fields-button"

Then "matched-fields-table" should contain 1 rows

When I select "*Position (position)" from the "form-fields" select
Then "*Position (position)" should be selected for "form-fields"

When I select "Well Positio" from the "fields-from-csv" select
Then "Well Positio" should be selected for "fields-from-csv"

Given I click on "match-fields-button"
Then "matched-fields-table" should contain 2 rows

When I select "*Scientific name (scientific_name)" from the "form-fields" select
When I select "sciname" from the "fields-from-csv" select

Given I click on "match-fields-button"
Then "matched-fields-table" should contain 3 rows

When I select "*Supplier name (supplier_name)" from the "form-fields" select
When I select "supname" from the "fields-from-csv" select

Given I click on "match-fields-button"
Then "matched-fields-table" should contain 4 rows

When I select "*Gender (gender)" from the "form-fields" select
When I select "ender" from the "fields-from-csv" select

Given I click on "match-fields-button"
Then "matched-fields-table" should contain 5 rows

When I select "*Donor ID (donor_id)" from the "form-fields" select
When I select "Dono" from the "fields-from-csv" select

Given I click on "match-fields-button"
Then "matched-fields-table" should contain 6 rows

When I select "Phenotype (phenotype)" from the "form-fields" select
When I select "Phenotyp" from the "fields-from-csv" select

Given I click on "match-fields-button"
Then "matched-fields-table" should contain 7 rows

When I select "*Tissue Type (tissue_type)" from the "form-fields" select
When I select "Tissue" from the "fields-from-csv" select

Given I click on "match-fields-button"
Then "matched-fields-table" should contain 8 rows

When I select "*Tumour? (is_tumour)" from the "form-fields" select
When I select "cancer" from the "fields-from-csv" select

Given I click on "match-fields-button"
Then "matched-fields-table" should contain 9 rows

Given I click on "complete-csv-matching"

Then I should see data from my file like a dropdown with "lysed cells" selected
Then I should see data from my file like a dropdown with "female" selected
Then I should see data from my file like a textbox containing "Homo sapiens"
