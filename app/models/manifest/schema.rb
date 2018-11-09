module Manifest::Schema

  def material_schema
    MatconClient::Material.schema
  end

  def manifest_schema
    @manifest_schema ||= material_schema.dup.tap do |schema|
      config = Rails.application.config.manifest_schema_config
      labware_name = config["field_labware_name"]
      position = config["field_position"]

      # Merges properties from the biomaterial schema and the manifest schema config to create a new schema object
      # The resulting schema will have all the information from the material schema but any fields defined in the manifest
      # schema config will overwrite its values. We duplicate any updated key object to not overwrite the material schema
      schema["properties"] = config["property_updates"].keys.reduce(schema["properties"].dup) do |memo, key|
        # We do not use merge! because we want to create new instances of the object to not overwrite the material schema
        memo[key] = (schema["properties"][key] || {}).merge(config["property_updates"][key])
        memo
      end

      # Here we will modify the manifest schema about decisions taken because of the manifest contents:
      # 'labware_name' is only required when there are several plates in the same manifest to be able to identify it
      schema["properties"][labware_name]["required"] = (labwares.count > 1)
      # 'position' is required when there are several positions to choose inside the same labware to put the sample in
      schema["properties"][position]["required"] = ((labwares.count > 0) && (labwares.first.positions.count > 1))
    end
    @manifest_schema
  end
end
