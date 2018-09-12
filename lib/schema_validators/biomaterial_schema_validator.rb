module SchemaValidators
  class BiomaterialSchemaValidator

    @@VALIDATION_CLASSES = [ 
      SchemaValidators::BiomaterialSchemaPropertyValidators::RequiredFieldValidator, 
      SchemaValidators::BiomaterialSchemaPropertyValidators::AllowedValuesValidator, 
      SchemaValidators::BiomaterialSchemaPropertyValidators::TaxonIdValidator,
      SchemaValidators::BiomaterialSchemaPropertyValidators::HmdmcValidator,
      SchemaValidators::BiomaterialSchemaPropertyValidators::UniqueValuesValidator 
    ]

    def self.VALIDATION_CLASSES
      @@VALIDATION_CLASSES
    end

    attr_reader :schema
    attr_accessor :error_messages
    attr_accessor :validators


    def initialize(schema)
      @schema = schema
      @error_messages = []
      build_validators(@schema)
    end

    # Get a field from the schema, not caring too much about which one
    def default_field
      sr = @schema['required']
      return sr.first.to_sym if sr && !sr.empty?
      sp = @schema['properties']
      return sp.keys.first.to_sym if sp && !sp.empty?
      nil
    end

    def properties_to_validate
      @schema['properties'].keys
    end

    def validate(labware_index, address, bio_data)
      properties_to_validate.each do |property_name|
        validators_for(property_name).each do |validator|
          validator.validate(labware_index, address, bio_data)
        end
      end
      error_messages.empty?
    end

    def validators_for(property_name)
      @validators[property_name]
    end

    private

    def build_validators(schema)
      @validators = schema['properties'].reduce({}) do |memo, prop|
        property_name, property_data = prop

        memo[property_name] = self.class.VALIDATION_CLASSES.select do |klass| 
          klass.is_applicable?(property_name, property_data)
        end.map do |klass| 
          klass.new(self, property_name, property_data)
        end

        memo
      end
    end
  end

end