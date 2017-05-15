# Service to deal with complicated "provenance" (i.e. data fields for biomaterial)
class ProvenanceService

  def initialize(schema)
    @schema = schema
  end

  # Checks the given labware data against the schema to see if it looks OK.
  # Returns an array of errors. If the list is empty, the data seems to be OK.
  def validate(labware_index, labware_data)
    return [] if @schema.nil?
    return [] if labware_data.nil?
    error_messages = []
    labware_data.each do |address, bio_data|
      @schema['properties'].each do | property_name, property_data|
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
              add_error(error_messages, labware_index, address, property_name, "The field #{property_name} needs to be one of the following: #{enum_items}.")
            else
              bio_data[property_name] = enum_items[i]
            end
          end
        end
      end
    end
    error_messages
  end

  # Process request to set the json data for labware in a given submission.
  # Returns a success boolean and an array of errors.
  # The data will be saved even if the validation failed, because it might be in-progress.
  # - [true, []] - nothing went wrong
  # - [false, [error1, error2, ...]] - some stuff went wrong; here is the information
  # - [false, []] - something unexpected went wrong
  def set_biomaterial_data(material_submission, labware_params)
    all_errors = []

    general_error_field = default_field

    success = true

    # remove null or empty data from the params
    material_submission.labwares.each do |labware|
      labware_index = labware.labware_index
      labware_data = labware_params[labware_index.to_s]
      filtered_data = {}
      if labware_data
        labware_data.each do |address, material_data|
          material_data.each do |fieldName, value|
            unless value.blank?
              filtered_data[address] = {} if filtered_data[address].nil?
              filtered_data[address][fieldName] = value.strip()
            end
          end
        end
      end


      filtered_data = nil if filtered_data.empty?

      if filtered_data.nil? && !general_error_field.nil?
        error_messages = [{
          errors: { general_error_field => "At least one material must be specified for each item of labware" },
          labwareIndex: labware_index,
          address: labware.positions[0],
          update_successful: false,
        }]
      else
        error_messages = validate(labware_index, filtered_data)
      end
      success &= labware.update_attributes(contents: filtered_data)
      all_errors += error_messages unless error_messages.empty?
    end
    success &= all_errors.empty?
    return success, all_errors
  end

private

  # Get a field from the schema, not caring too much about which one
  def default_field
    sr = @schema['required']
    return sr.first.to_sym if sr && !sr.empty?
    sp = @schema['properties']
    return sp.keys.first.to_sym if sp && !sp.empty?
    nil
  end

  # Adds a validation error to the given error_messages.
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
