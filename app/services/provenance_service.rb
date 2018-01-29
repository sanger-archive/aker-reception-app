require 'schema_validators'

# Service to deal with complicated "provenance" (i.e. data fields for biomaterial)
class ProvenanceService

  attr_accessor :schema_validator

  def initialize(schema)
    @schema_validator = SchemaValidators::BiomaterialSchemaValidator.new(schema)
  end

  # Checks the given labware data against the schema to see if it looks OK.
  # Returns an array of errors. If the list is empty, the data seems to be OK.
  def validate(labware_index, labware_data)
    schema_validator.error_messages = []

    if labware_data.empty? && !schema_validator.default_field.nil?
      schema_validator.error_messages = [{
        errors: { schema_validator.default_field => "At least one material must be specified for each item of labware" },
        labwareIndex: labware_index,
        address: labware_data.keys.first,
        update_successful: false,
      }]
    else
      return [] if labware_data.empty?

      labware_data.each do |address, bio_data|
        schema_validator.validate(labware_index, address, bio_data)
      end

      schema_validator.error_messages
    end
  end

  # Process request to set the json data for labware in a given submission.
  # Returns a success boolean and an array of errors.
  # The data will be saved even if the validation failed, because it might be in-progress.
  # - [true, []] - nothing went wrong
  # - [false, [error1, error2, ...]] - some stuff went wrong; here is the information
  # - [false, []] - something unexpected went wrong
  def set_biomaterial_data(material_submission, labware_params, current_user)
    all_errors = []

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

              # Add HMDMC set_by field for each sample
              filtered_data[address]['hmdmc_set_by'] = current_user.email if fieldName == 'hmdmc'
            end
          end
        end
      end

      error_messages = validate(labware_index, filtered_data)
      filtered_data = nil if filtered_data.empty?

      success &= labware.update_attributes(contents: filtered_data)
      all_errors += error_messages unless error_messages.empty?
    end
    success &= all_errors.empty?
    return success, all_errors
  end

end
