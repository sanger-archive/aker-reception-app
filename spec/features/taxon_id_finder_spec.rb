require 'rails_helper'
require 'webmock/rspec'
require 'support/stub_helper'
require 'support/wait_for_ajax'

RSpec.feature 'TaxonIdFinder', type: :feature, js: true do
  include StubHelper
  include WaitForAjax

  describe 'TaxonomyIdControl' do
    let(:user) { OpenStruct.new(:email => 'user@sanger.ac.uk', :groups => ['world']) }

    before do
      WebMock.disable_net_connect!(:allow_localhost => true)

      allow(MatconClient::Material).to receive(:schema).and_return({
        'required' => ['tax_id', 'scientific_name', 'supplier_name', 'donor_id', 'gender', 'phenotype'],
        'properties' => {
          'supplier_name' => {'required' => true, 'friendly_name' => 'Supplier name', 'field_name_regex' => "^supplier[-_\s]*(name)?$"},
          'donor_id' => {'required' => true, 'friendly_name' => 'Donor Id', 'field_name_regex' => "^donor[-_\s]*(id)?$"},
          'gender' => {'required' => true, 'friendly_name' => 'Gender','field_name_regex' => "^gender$"},
          'phenotype' => {'required' => true, 'friendly_name' => 'Phenotype','field_name_regex' => "^phenotype$"},
          'tax_id' => {
            'required' => true,
            'friendly_name' => "Tax Id",
            'field_name_regex' => "^tax[-_\s]*(id)?$",
          },
          'scientific_name' => {
            'required' => true,
            'field_name_regex' => "^scientific[-_\s]*(name)?$",
            'allowed' => ['Homo sapiens', 'Mus musculus'],
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
          visit material_submission_build_path(material_submission_id: matsub.id, id: 'provenance')
        end
        context 'when writing a taxonomy id in a single input' do
          it 'uses the taxonomy service and searches for the id provided', js: true  do
            fill_in('labware[1]address[A:1]fieldName[tax_id]', with: '1234')
            sleep(5)
            wait_for_ajax
            expect(page).to have_selector(".has-success")
            expect(find_by_id('labware[1]address[A:1]fieldName[scientific_name]').value.length>0).to eq(true)
          end
        end
        context 'when uploading a manifest' do
          before do
            attach_file('Upload CSV', File.absolute_path("test/data/manifest_with_tax_id.csv"), make_visible: true)
          end
          it 'validates in the server using the taxonomy service', js: true  do
            tax_info = double('taxonomy_info', {taxId: '9606', scientificName: 'Homo sapiens'})
            allow(TaxonomyClient::Taxonomy).to receive(:find).with("9606").and_return(tax_info)

            within(first('form > .row > .col-md-12')) { click_on('Next') }
            
            expect(page).not_to have_selector(".has-error")
          end
        end

      end
    end
  end
end