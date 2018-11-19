class Manifest::ProvenanceState
  attr_reader :state, :manifest, :user
  attr_reader :schema, :mapping, :content

  delegate :manifest_schema_field, to: :schema
  delegate :manifest_schema, to: :schema
  delegate :labwares, to: :manifest

  class WrongNumberLabwares < StandardError ; end

  def initialize(manifest, user)
    @manifest = manifest
    @user = user

    @schema = Schema.new(self)
    @mapping = Mapping.new(self)
    @content = Content.new(self)
  end

  def apply(state)
    @state = (state.dup || _build_state)

    @schema.apply(@state)
    @mapping.apply(@state)
    @content.apply(@state) if @mapping.valid?

    validate if @mapping.valid?
    save
    @state
  end

  def validate
    if @state[:content][:structured][:labwares]
      num_labwares_file = @state[:content][:structured][:labwares].keys.length
      num_labwares_manifest = @manifest.labwares.count
      if (num_labwares_file > num_labwares_manifest)
        raise WrongNumberLabwares.new("Expected #{num_labwares_manifest} labwares in Manifest but found #{num_labwares_file}.")
      elsif (num_labwares_file < num_labwares_manifest)
        raise WrongNumberLabwares.new("Expected #{num_labwares_manifest} labwares in Manifest but could only find #{num_labwares_file}.")
      end
    end
  end

  def save
    if valid?
      update(state[:updates])
    end
  end

  def update(updates)
    if updates
      if valid?
        debugger
        provenance = ProvenanceService.new(@manifest.manifest_schema)
        messages = provenance.set_biomaterial_data(@manifest, updates, @user)
        @manifest_update_state.apply_messages(messages)
      end
    end
  end

  def valid?
    @mapping.valid? && @content.valid?
  end


  def apply_messages(messages)
    @content = {}
  end

  def _build_state
    {
      manifest: {
        id: @manifest.id,
        schema: nil,
        content: nil,
        mapping: nil
      }
    }
  end

end
