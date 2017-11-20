module SchemaValidators
  module BiomaterialSchemaPropertyValidators
    class TaxonIdValidator < BiomaterialSchemaPropertyValidator
      attr_reader :taxonomies_memoized

      def self.is_applicable?(property_name, property_data)
        property_name == 'tax_id'
      end

      def find_by_tax_id(tax_id)
        if taxonomies_memoized.nil?
          @taxonomies_memoized = {}
        end
        if !taxonomies_memoized[tax_id]
          taxonomies_memoized[tax_id] = TaxonomyClient::Taxonomy.find(tax_id)
        end
        taxonomies_memoized[tax_id]
      end

      def validate(labware_index, address, bio_data)
        return true if field_data(bio_data).nil?

        tax_id = field_data_for_property('tax_id', bio_data)
        scientific_name = field_data_for_property('scientific_name', bio_data)
        begin
          obtained_value = find_by_tax_id(tax_id).scientificName
        rescue TaxonomyClient::Errors::NotFound => e
          add_error(labware_index, address, property_name, "The Tax Id provided (#{tax_id}) was not found in the EBI Taxonomy service")
          return false          
        end

        if tax_id == '1'
          add_error(labware_index, address, property_name, "The Tax Id provided 1 for Root is not a valid taxonomy id.")
          return false
        end
        unless scientific_name == obtained_value
          add_error(labware_index, address, property_name, "The Tax Id provided (#{tax_id}) does not match the scientific name provided '#{scientific_name}'. The taxonomy service indicates it should be '#{obtained_value}.")
          return false
        end
        true
      end
    end
  end
end