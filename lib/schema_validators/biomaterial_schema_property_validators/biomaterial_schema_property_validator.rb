module SchemaValidators
  module BiomaterialSchemaPropertyValidators

    class BiomaterialSchemaPropertyValidator
      attr_accessor :schema_validator
      attr_accessor :property_name
      attr_accessor :property_data

      def initialize(schema_validator, property_name, property_data)
        @property_name = property_name
        @property_data = property_data
        @schema_validator = schema_validator
      end

      def error_messages
        schema_validator.error_messages
      end

      def warning_messages
        schema_validator.warning_messages
      end

      def field_data(bio_data)
        field_data_for_property(property_name, bio_data)
      end

      # Adds a validation error to the given error_messages.
      def add_error(labware_index, address, field, msg)
        i = error_messages.index { |x| x[:labwareIndex]==labware_index && x[:address]==address }
        if i.nil?
          error_message = {
            errors: {},
            labwareIndex: labware_index,
            address: address,
            update_successful: true,
          }
          error_messages.push(error_message)
        else
          error_message = error_messages[i]
        end
        error_message[:errors][field.to_sym] = msg
      end

      # Adds a validation error to the given warning_messages.
      def add_warning(labware_index, address, field, msg)
        i = warning_messages.index { |x| x[:labwareIndex]==labware_index && x[:address]==address }
        if i.nil?
          warning_message = {
            warnings: {},
            labwareIndex: labware_index,
            address: address,
            update_successful: true,
          }
          warning_messages.push(warning_message)
        else
          warning_message = warning_messages[i]
        end
        warning_message[:warnings][field.to_sym] = msg
      end


      def field_data_for_property(property_name, bio_data)
        field_data = bio_data[property_name]
        field_data = field_data.strip if field_data
        field_data = nil if field_data and field_data.empty?
        field_data
      end

    end
  end
end
