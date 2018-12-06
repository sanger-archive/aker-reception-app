class Manifest::ProvenanceState
  attr_reader :state, :manifest, :user
  attr_reader :schema, :mapping, :content, :manifest_model

  delegate :manifest_schema_field, to: :schema
  delegate :manifest_schema_field_required?, to: :schema
  delegate :manifest_schema, to: :schema
  delegate :labwares, to: :manifest

  class WrongNumberLabwares < StandardError ; end

  def initialize(manifest, user)
    @state = {}
    @user = user
    @manifest_model = manifest

    @services = ServicesAccessor.new(self, :services)
    @manifest = ManifestAccessor.new(self, :manifest)
    @schema = SchemaAccessor.new(self, :schema)
    @mapping = MappingAccessor.new(self, :mapping)
    @content = ContentAccessor.new(self, :content)
    @store = StoreAccessor.new(self, :content)
  end

  def apply(state)
    @state = (state.dup || build_state)

    @services.apply(@state)
    @manifest.apply(@state)
    @schema.apply(@state)
    @mapping.apply(@state)
    @content.apply(@state)
    @store.apply(@state)

    @state
  end



  def _build_state
    {
      id: @manifest_model.id,
      schema: nil,
      content: nil,
      mapping: nil
    }
  end

end
