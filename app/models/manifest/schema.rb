module Manifest::Schema

  def material_schema
    MatconClient::Material.schema
  end

  def manifest_schema
    @manifest_schema ||= material_schema.dup.tap do |schema|
      config = Rails.application.config.manifest_schema_config
      labware_name = config["field_labware_name"]
      position = config["field_position"]
      schema["properties"] = schema["properties"].merge(config["property_additions"])

      # labware_name is only required when there are several plates in the same manifest to be able to identify it
      schema["properties"][labware_name]["required"] = (labwares.count > 1)
      # position is required when there are several positions to choose inside the same labware to put the sample in
      schema["properties"][position]["required"] = ((labwares.count > 0) && (labwares.first.positions.count > 1))
    end
    @manifest_schema
  end
end
