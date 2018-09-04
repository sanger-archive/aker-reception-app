module SchemaValidators
  module BiomaterialSchemaPropertyValidators
    class UniqueValuesValidator < BiomaterialSchemaPropertyValidator

      def self.is_applicable?(property_name, property_data)
        property_data['unique_value'] == true
      end

      def validate(labware_index, address, bio_data)
        return true if field_data(bio_data).nil?
        success = true

        value = field_data(bio_data)
        prepare_memoized_values(labware_index, property_name)
        if is_duplicated?(labware_index, property_name, value)
          add_error(labware_index, address, property_name, "The field #{property_name} has a duplicate value #{value} at #{address}")
          success = false
        else
          add_memoized_value(labware_index, property_name, value)
        end

        success
      end

      private
      def prepare_memoized_values(labware_index, property_name)
        @memoized_values = {} if @memoized_values.nil?
        @memoized_values[property_name] = [] unless @memoized_values[property_name]        
      end

      def add_memoized_value(labware_index, property_name, value)
        @memoized_values[property_name].push(value)
      end

      def is_duplicated?(labware_index, property_name, value)
        @memoized_values[property_name].include?(value)
      end

    end
  end
end