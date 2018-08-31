module SchemaValidators
  module BiomaterialSchemaPropertyValidators
    require_relative 'biomaterial_schema_property_validators/biomaterial_schema_property_validator'
    require_relative 'biomaterial_schema_property_validators/allowed_values_validator'
    require_relative 'biomaterial_schema_property_validators/required_field_validator'
    require_relative 'biomaterial_schema_property_validators/taxon_id_validator'    
    require_relative 'biomaterial_schema_property_validators/hmdmc_validator'    
    require_relative 'biomaterial_schema_property_validators/unique_values_validator'    
  end
end