module SchemaValidators
  module BiomaterialSchemaPropertyValidators
    class RequiredFieldValidator < BiomaterialSchemaPropertyValidator
      def self.is_applicable?(property_name, property_data)
        property_data['required']
      end

      def validate(labware_index, address, bio_data)
        if field_data(bio_data).nil?
          add_error(labware_index, address, property_name, "The required field #{property_name} is not given.")
          return false
        end
        true
      end
    end
  end
end