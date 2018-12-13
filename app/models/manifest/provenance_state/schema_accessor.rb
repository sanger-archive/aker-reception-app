class Manifest::ProvenanceState::SchemaAccessor < Manifest::ProvenanceState::Accessor

  delegate :labwares, to: :provenance_state

  # Accessor methods
  def manifest_schema_field(sym)
    config = Rails.application.config.manifest_schema_config
    return config["field_labware_name"] if sym == :labware_id
    return config["field_position"] if sym == :position
    sym
  end

  def manifest_schema_field_required?(sym)
    manifest_schema["properties"][sym]["required"]
  end

  # Build methods

  def build
    manifest_schema
  end

  def material_schema
    MatconClient::Material.schema
  end

  def manifest_schema
    return @manifest_schema if @manifest_schema
    config = Rails.application.config.manifest_schema_config
    @manifest_schema = material_schema.dup.tap do |schema|

      # Merges properties from the biomaterial schema and the manifest schema config to create a new schema object
      # The resulting schema will have all the information from the material schema but any fields defined in the manifest
      # schema config will overwrite its values. We duplicate any updated key object to not overwrite the material schema
      schema["properties"] = config["property_updates"].keys.reduce(schema["properties"].dup) do |memo, key|
        # We do not use merge! because we want to create new instances of the object to not overwrite the material schema
        memo[key] = (schema["properties"][key] || {}).merge(config["property_updates"][key])
        memo
      end

      _build_show_on_form(schema)

      # Here we will modify the manifest schema about decisions taken because of the manifest contents:
      # 'labware_name' is only required when there are several plates in the same manifest to be able to identify it
      schema["properties"][manifest_schema_field(:labware_id)]["required"] = (labwares.length > 1)
      schema["properties"][manifest_schema_field(:labware_id)]["show_on_form"] = (labwares.length > 1)
      # 'position' is required when there are several positions to choose inside the same labware to put the sample in
      schema["properties"][manifest_schema_field(:position)]["required"] = false
      schema["properties"][manifest_schema_field(:position)]["show_on_form"] = false
      if (labwares.length > 0)
        if labwares[0][:positions]
          schema["properties"][manifest_schema_field(:position)]["required"] = (labwares[0][:positions].length > 1)
          schema["properties"][manifest_schema_field(:position)]["show_on_form"] = (labwares[0][:positions].length > 1)
        end
      end
    end
    @manifest_schema
  end

  private

  def _build_show_on_form(schema)
    unless schema["show_on_form"]
      schema["show_on_form"] = schema["properties"].keys.reduce([]) do |m,k|
        m.push(k) if schema["properties"][k]["show_on_form"]
        m
      end
    end
  end

end
