require 'rails_helper'
require 'support/stub_helper'
# require 'support/wait_for_ajax'

RSpec.feature 'TaxonIdFinder', type: :feature, js: true do
  include StubHelper
  # include WaitForAjax

  describe 'TaxonomyIdControl' do
    let(:user) { OpenStruct.new(email: 'user@sanger.ac.uk', groups: ['world']) }

    before do

      allow(MatconClient::Material).to receive(:schema).and_return({
        'show_on_form' => ['taxon_id', 'scientific_name', 'supplier_name', 'donor_id', 'gender', 'phenotype'],
        'required' => ['taxon_id', 'scientific_name', 'supplier_name', 'donor_id', 'gender', 'phenotype'],
        'properties' => {
          'supplier_name' => {'type': 'string', 'required' => true, 'friendly_name' => 'Supplier name', 'field_name_regex' => "^supplier[-_\s]*(name)?$"},
          'donor_id' => {'type': 'string', 'required' => true, 'friendly_name' => 'Donor Id', 'field_name_regex' => "^donor[-_\s]*(id)?$"},
          'gender' => {'type': 'string', 'required' => true, 'friendly_name' => 'Gender','field_name_regex' => "^gender$"},
          'phenotype' => {'type': 'string', 'required' => true, 'friendly_name' => 'Phenotype','field_name_regex' => "^phenotype$"},
          'taxon_id' => {'type': 'string',
            'required' => true,
            'friendly_name' => "Tax Id",
            'field_name_regex' => "^tax[-_\s]*(id)?$",
          },
          'scientific_name' => {'type': 'string',
            'required' => true,
            'field_name_regex' => "^scientific[-_\s]*(name)?$",
            'friendly_name' => "Scientific name"
          }
        }
      })

      allow_any_instance_of(JWTCredentials).to receive(:check_credentials)
      allow_any_instance_of(JWTCredentials).to receive(:current_user).and_return(user)
    end

    context 'when creating a new submission' do
      let(:matsub) {
        matsub = create(:material_submission, #no_of_labwares_required: 1,
          supply_labwares: false,
          owner_email: user.email)
        lt=create(:labware_type,
              name: 'Some lt',
              description: 'lt',
              num_of_cols: 12,
              num_of_rows: 8,
              col_is_alpha: false,
              row_is_alpha: true
              )
        matsub.update_attributes(labware_type: lt, no_of_labwares_required: 1)
        matsub.save
        matsub
      }
      context 'when writing the provenance information' do
        before do
          tax_info = double('taxonomy_info', {taxId: '3', scientificName: 'One specie'})
          tax_info2 = double('taxonomy_info', {taxId: '4', scientificName: 'Another different one'})
          cached_taxonomies = [tax_info, tax_info2].reduce({}) do |memo, elem|
            memo[elem.taxId] = {taxId: elem.taxId, scientificName: elem.scientificName}
            memo
          end

          allow_any_instance_of(SubmissionsController).to receive(:cached_taxonomies).and_return(cached_taxonomies)

          allow(TaxonomyClient::Taxonomy).to receive(:find).with("3").and_return(tax_info)
          allow(TaxonomyClient::Taxonomy).to receive(:find).with("4").and_return(tax_info2)

          visit material_submission_build_path(material_submission_id: matsub.id, id: 'provenance')
        end
        context 'when writing a taxonomy id in a single input' do
          it 'uses the taxonomy service and searches for the id provided', js: true  do
            fill_in('labware[1]address[A:1]fieldName[taxon_id]', with: '3')
            puts current_url
            # binding.pry
            # wait_for_ajax
            expect(page).to have_selector(".has-success")
            expect(find_by_id('labware[1]address[A:1]fieldName[scientific_name]').value.length>0).to eq(true)
          end
        end

        context 'when sending the form' do

          context 'when writing a taxonomy id in different inputs' do

            it 'uses the taxonomy service and searches for the id provided once for each different tax id', js: true  do

              i=0
              fill_in("labware[1]address[A:#{i+1}]fieldName[taxon_id]", with: '3')
              fill_in("labware[1]address[A:#{i+1}]fieldName[supplier_name]", with: '3')
              fill_in("labware[1]address[A:#{i+1}]fieldName[donor_id]", with: '3')
              fill_in("labware[1]address[A:#{i+1}]fieldName[gender]", with: 'male')
              fill_in("labware[1]address[A:#{i+1}]fieldName[phenotype]", with: '3')

              fill_in("labware[1]address[B:#{i+1}]fieldName[taxon_id]", with: '4')
              fill_in("labware[1]address[B:#{i+1}]fieldName[supplier_name]", with: '4')
              fill_in("labware[1]address[B:#{i+1}]fieldName[donor_id]", with: '4')
              fill_in("labware[1]address[B:#{i+1}]fieldName[gender]", with: 'female')
              fill_in("labware[1]address[B:#{i+1}]fieldName[phenotype]", with: '4')
              # wait_for_ajax
              within(first('form > .row > .col-md-12')) { click_on('Next') }
              expect(page).not_to have_selector(".has-error")
            end
          end
        end
      end
    end
  end
end
