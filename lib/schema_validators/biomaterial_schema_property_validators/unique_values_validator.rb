module SchemaValidators
  module BiomaterialSchemaPropertyValidators
    class UniqueValuesValidator < BiomaterialSchemaPropertyValidator

      def self.is_applicable?(property_name, property_data)
        property_data['unique'] == true
      end

      def prepare_memoized_values(labware_index, property_name)
        @memoized_values = {} if @memoized_values.nil?
        @memoized_values[labware_index] = {} unless @memoized_values[labware_index]
        @memoized_values[labware_index][property_name] = [] unless @memoized_values[labware_index][property_name]        
      end

      def validate(labware_index, address, bio_data)
        return true if field_data(bio_data).nil?
        success = true

        value = field_data(bio_data)
        prepare_memoized_values(labware_index, property_name)
        if @memoized_values[labware_index][property_name].include?(value)
          add_error(labware_index, address, property_name, "The field #{property_name} has a duplicate value #{value} at #{address}")
          success = false
        else
          @memoized_values[labware_index][property_name].push(value)
        end

        success
      end
    end
  end
end