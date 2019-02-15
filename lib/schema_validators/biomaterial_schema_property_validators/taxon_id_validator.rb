module SchemaValidators
  module BiomaterialSchemaPropertyValidators
    class TaxonIdValidator < BiomaterialSchemaPropertyValidator
      attr_reader :taxonomies_memoized

      def self.is_applicable?(property_name, property_data)
        property_name == 'taxon_id'
      end

      def is_integer(val)
        Integer(val) rescue false
      end

      def find_by_taxon_id(taxon_id)
        if taxonomies_memoized.nil?
          @taxonomies_memoized = {}
        end
        if !taxonomies_memoized[taxon_id]
          taxonomies_memoized[taxon_id] = TaxonomyClient::Taxonomy.find(taxon_id)
        end
        taxonomies_memoized[taxon_id]
      end

      def validate_scientific_name(taxon_id, scientific_name, location, bio_data)
        begin
          obtained_value = find_by_taxon_id(taxon_id).scientificName
        rescue TaxonomyClient::Errors::BadRequest => e
          add_error(location[:labware_index], location[:address], location[:property_name],
            "The request to the EBI Taxonomy service is not valid")
          return false
        rescue TaxonomyClient::Errors::NotFound => e
          add_error(location[:labware_index], location[:address], location[:property_name],
            "The Taxon Id provided (#{taxon_id}) was not found in the EBI Taxonomy service")
          return false
        end

        unless scientific_name == obtained_value
          if scientific_name
            add_warning(location[:labware_index], location[:address], location[:property_name],
              "The Taxon Id provided (#{taxon_id}) does not match the scientific name provided '#{scientific_name}'.
              The taxonomy service indicates it should be '#{obtained_value} so the value provided will be ignored.")
          end
          set_field_data_for_property('scientific_name', bio_data, obtained_value)
        end

        true
      end

      def validate(labware_index, address, bio_data)
        return true if field_data(bio_data).nil?

        taxon_id = field_data_for_property('taxon_id', bio_data)
        unless is_integer(taxon_id)
          add_error(labware_index, address, 'taxon_id', "The taxon id provided is not a number")
          return false
        end
        scientific_name = field_data_for_property('scientific_name', bio_data)

        location = {labware_index: labware_index, address: address, property_name: property_name}
        validate_scientific_name(taxon_id, scientific_name, location, bio_data)
      end
    end
  end
end
