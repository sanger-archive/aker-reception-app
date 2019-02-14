# frozen_string_literal: true

require 'rails_helper'
require 'support/stub_helper'

RSpec.feature 'TaxonIdFinder', type: :feature, js: true do
  include StubHelper

  describe 'TaxonomyIdControl' do
    let(:user) { OpenStruct.new(email: 'user@sanger.ac.uk', groups: ['world']) }

    before do
      allow(MatconClient::Material).to receive(:schema).and_return(
        'show_on_form' => %w[taxon_id scientific_name supplier_name donor_id gender phenotype],
        'required' => %w[taxon_id scientific_name supplier_name donor_id gender phenotype],
        'properties' => {
          'supplier_name' => { 'type': 'string',
                               'required' => true,
                               'friendly_name' => 'Supplier name',
                               'field_name_regex' => "^supplier[-_\s]*(name)?$" },
          'donor_id' => { 'type': 'string',
                          'required' => true,
                          'friendly_name' => 'Donor Id',
                          'field_name_regex' => "^donor[-_\s]*(id)?$" },
          'gender' => { 'type': 'string',
                        'required' => true,
                        'friendly_name' => 'Gender',
                        'field_name_regex' => '^gender$' },
          'phenotype' => { 'type': 'string',
                           'required' => true,
                           'friendly_name' => 'Phenotype',
                           'field_name_regex' => '^phenotype$' },
          'taxon_id' => { 'type': 'string',
                          'required' => true,
                          'friendly_name' => 'Tax Id',
                          'field_name_regex' => "^tax[-_\s]*(id)?$" },
          'scientific_name' => { 'type': 'string',
                                 'required' => true,
                                 'field_name_regex' => "^scientific[-_\s]*(name)?$",
                                 'friendly_name' => 'Scientific name' }
        }
      )

      allow_any_instance_of(JWTCredentials).to receive(:check_credentials)
      allow_any_instance_of(JWTCredentials).to receive(:current_user).and_return(user)
    end

    context 'when creating a new submission' do
      let(:matsub) do
        matsub = create(:manifest,
                        supply_labwares: false,
                        owner_email: user.email)
        lt = create(:labware_type,
                    name: 'Some lt',
                    description: 'lt',
                    num_of_cols: 12,
                    num_of_rows: 8,
                    col_is_alpha: false,
                    row_is_alpha: true)
        matsub.update_attributes(labware_type: lt, no_of_labwares_required: 1)
        matsub.save
        matsub
      end
      context 'when writing the provenance information' do
        before do
          tax_info = double('taxonomy_info', taxId: '3', scientificName: 'Some specie name')
          tax_info2 = double('taxonomy_info', taxId: '4', scientificName: 'Some specie name')
          cached_taxonomies = [tax_info, tax_info2].each_with_object({}) do |elem, memo|
            memo[elem.taxId] = { taxId: elem.taxId, scientificName: elem.scientificName }
            memo
          end

          allow_any_instance_of(SubmissionsController).to receive(:cached_taxonomies)
            .and_return(cached_taxonomies)

          allow(TaxonomyClient::Taxonomy).to receive(:find).with('3').and_return(tax_info)
          allow(TaxonomyClient::Taxonomy).to receive(:find).with('4').and_return(tax_info2)

          visit manifest_build_path(manifest_id: matsub.id, id: 'provenance')
        end
        context 'when writing a taxonomy id in a single input' do
          it 'uses the taxonomy service and searches for the id provided on blur event', js: true do
            fill_in('labware[0]address[A:1]fieldName[taxon_id]', with: '3')
            page.find("body").click

            expect(page).to have_selector("input[value='Some specie name']")
          end
        end

        context 'when sending the form' do
          context 'when writing a taxonomy id in different inputs' do
            it 'uses the taxonomy service and searches for the id provided', js: true do
              i = 0
              fill_in("labware[0]address[A:#{i + 1}]fieldName[taxon_id]", with: '3')
              fill_in("labware[0]address[A:#{i + 1}]fieldName[supplier_name]", with: '3')
              fill_in("labware[0]address[A:#{i + 1}]fieldName[donor_id]", with: '3')
              fill_in("labware[0]address[A:#{i + 1}]fieldName[gender]", with: 'male')
              fill_in("labware[0]address[A:#{i + 1}]fieldName[phenotype]", with: '3')

              fill_in("labware[0]address[B:#{i + 1}]fieldName[taxon_id]", with: '4')
              fill_in("labware[0]address[B:#{i + 1}]fieldName[supplier_name]", with: '4')
              fill_in("labware[0]address[B:#{i + 1}]fieldName[donor_id]", with: '4')
              fill_in("labware[0]address[B:#{i + 1}]fieldName[gender]", with: 'female')
              fill_in("labware[0]address[B:#{i + 1}]fieldName[phenotype]", with: '4')

              first('a.save').click
              expect(page).not_to have_selector('.has-error')
            end
          end
        end
      end
    end
  end
end
