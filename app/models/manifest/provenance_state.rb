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

    @manifest = ManifestAccessor.new(self)
    @services = Manifest::ProvenanceState::Services.new(self)
    @schema = Schema.new(self)
    @mapping = Mapping.new(self)
    @content = Content.new(self)
  end

  def apply(state)
    @state = (state.dup || _build_state)

    @services.apply(@state)
    @manifest.apply(@state)
    @schema.apply(@state)
    @mapping.apply(@state)
    @content.apply(@state, @manifest_model)

    validate if @mapping.valid?
    save
    @state
  end

  def validate
    if @state[:content][:structured][:labwares]
      num_labwares_file = @state[:content][:structured][:labwares].keys.length
      num_labwares_manifest = @manifest_model.labwares.count
      if (num_labwares_file > num_labwares_manifest)
        raise WrongNumberLabwares.new("Expected #{num_labwares_manifest} labwares in Manifest but found #{num_labwares_file}.")
      elsif (num_labwares_file < num_labwares_manifest)
        raise WrongNumberLabwares.new("Expected #{num_labwares_manifest} labwares in Manifest but could only find #{num_labwares_file}.")
      end
    end
  end

  def save

    if valid?
      updates = updates_for(@state[:content][:structured][:labwares])
      update(updates)
    end
  end

  def updates_for(obj)
    obj.keys.reduce({}) do |memo_labware, labware_key|
      memo_labware[labware_key.to_s] = {
        "contents" =>  obj[labware_key][:addresses].keys.reduce({}) do |memo_address, address_key|
          memo_address[address_key] = obj[labware_key][:addresses][address_key][:fields].keys.reduce({}) do |memo_fields, field_key|
            memo_fields[field_key] = obj[labware_key][:addresses][address_key][:fields][field_key][:value]
            memo_fields
          end
          memo_address
        end
      }
      memo_labware
    end
  end

  def update(updates)
    if updates
      if valid?
        provenance = ProvenanceService.new(@schema.manifest_schema)
        messages = provenance.set_biomaterial_data(@manifest_model, updates, @user)
        #@manifest_update_state.apply_messages(messages)
      end
    end
  end

  def valid?
    @content.valid?
  end


  def apply_messages(messages)
    @content = {}
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
