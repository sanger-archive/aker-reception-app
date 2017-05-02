# Service to deal with complicated "provenance" (i.e. data fields for biomaterial)
class ProvenanceService

  def validate(schema, labware_index, labware_data)
    return [] if schema.nil?
    return [] if labware_data.nil?
    error_messages = []
    labware_data.each do |address, bio_data|
      schema['properties'].each do | property_name, property_data|
        field_data = bio_data[property_name]
        field_data = field_data.strip if field_data
        field_data = nil if field_data and field_data.empty?
        if field_data.nil?
          if property_data['required']
            add_error(error_messages, labware_index, address, property_name, "The required field #{property_name} is not given.")
          end
        else
          enum_items = property_data['enum']
          if enum_items
            i = enum_items.index { |x| x.casecmp(field_data)==0 }
            if i.nil?
              add_error(error_messages, labware_index, address, property_name, "The required field #{property_name} needs to be one of the following: #{enum_items}.")
            else
              bio_data[property_name] = enum_items[i]
            end
          end
        end
      end
    end
    return error_messages
  end

  def add_error(error_messages, labware_index, address, field, msg)
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

end