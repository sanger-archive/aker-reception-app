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

      def _add_message(store, key, message_data)
        i = store.index do |x|
          x[:labwareIndex]==message_data[:labware_index] && x[:address]==message_data[:address]
        end
        if i.nil?
          message = {
            labwareIndex: message_data[:labware_index],
            address: message_data[:address],
            update_successful: true,
          }
          message[key]={}
          store.push(message)
        else
          message = store[i]
        end
        message[key][message_data[:field].to_sym] = message_data[:text]
      end

      # Adds a validation error to the given error_messages.
      def add_error(labware_index, address, field, msg)
        _add_message(error_messages, :errors, {labware_index: labware_index, address: address, field: field, text: msg})
      end

      # Adds a validation error to the given warning_messages.
      def add_warning(labware_index, address, field, msg)
        _add_message(warning_messages, :warnings, {labware_index: labware_index, address: address, field: field, text: msg})
      end


      def field_data_for_property(property_name, bio_data)
        field_data = bio_data[property_name]
        field_data = field_data.strip if field_data
        field_data = nil if field_data and field_data.empty?
        field_data
      end

      def set_field_data_for_property(property_name, bio_data, value)
        bio_data[property_name]=value
      end

    end
  end
end
