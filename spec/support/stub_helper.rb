module StubHelper

  def stub_matcon_client_schema
    allow(MatconClient::Material).to receive(:schema).and_return({
        'required' => ['taxon_id', 'supplier_name', 'gender', 'donor_id', 'phenotype'],
        'properties' => {
          'taxon_id' => {
            'required' => true,
            'friendly_name' => "Taxon Id",
            'field_name_regex' => "^taxon[-_\s]*(id)?$",
          },
          'supplier_name' => {
            'required' => true,
            'friendly_name' => "Supplier name",
            'field_name_regex' => "^supplier[-_\s]*(name)?$",
          },
          'scientific_name' => {
            'required' => false,
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
        }
      })
  end
end