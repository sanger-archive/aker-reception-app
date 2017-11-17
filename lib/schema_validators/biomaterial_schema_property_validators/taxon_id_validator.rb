module SchemaValidators
  module BiomaterialSchemaPropertyValidators
    class TaxonIdValidator < BiomaterialSchemaPropertyValidator
      def self.is_applicable?(property_name, property_data)
        property_name == 'tax_id'
      end

      def validate(labware_index, address, bio_data)
        return true if field_data(bio_data).nil?

        tax_id = field_data_for_property('tax_id', bio_data)
        scientific_name = field_data_for_property('scientific_name', bio_data)

        obtained_value = TaxonomyClient.find(tax_id).scientific_name
        unless scientific_name == obtained_value
          add_error(labware_index, address, property_name, "The Tax Id provided (#{tax_id}) does not match the scientific name provided '#{scientific_name}'. The taxonomy service indicates it should be '#{obtained_value}.")
          return false
        end
        true
      end
    end
  end
end