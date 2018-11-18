class ManifestUpdateService
  def initialize(manifest, user)
    @manifest = manifest
    @user = user
  end

  def process(state)
    @manifest_update_state = Manifest::ProvenanceState.new(@manifest, @user)
    @manifest_update_state.apply(state)
    return @manifest_update_state.state

    if @manifest_update_state.valid?
      provenance = ProvenanceService.new(@manifest.manifest_schema)
      messages = provenance.set_biomaterial_data(@manifest, @manifest_update_state.updates, @user)
      @manifest_update_state.apply_messages(messages)
    end
    @manifest_update_state.state

    update unless manifest_update_state.updated?

    manifest_update_state.state

    if @manifest_update_state.valid?
      @manifest_update_state.save
    end
    @manifest_update_state.state
    @state = state
    build_mapping(state) if @state[:content][:raw] && !@state[:mapping]
    @contents = state[:content][:raw]
  end

  def save_updates(updates)
    ProvenanceService.new(@manifest.manifest_schema).set_biomaterial_data(@manifest, updates, @user)
  end



  def has_raw_content?
    !@state[:content][:raw].nil?
  end

  def has_mapping?
    !@state[:mapping]
  end

  def process_array(array)
    @contents = array
    @mapping = build_mapping
    save_mapped_contents(mapped_array_params(array))
    build_state
  end

  def process_state(state)
    @contents = state[:content]
    @mapping = state[:mapping]
    validate_mapping
    if mapping.valid?
    save_mapped_contents(mapped_labware_params(state[:content]))
    build_state
  end

  private

  def validate_mapping
    @mapping[:valid] = (required_unmatched_fields.length == 0) unless (@mapping.has_key(:valid))
  end

  def required_unmatched_fields
    required_schema_fields.select{|f| matched_expected_fields.include(f)}
  end

  def matched_expected_fields
    @mapping[:matched].map{|m| m[:expected]}
  end

  def required_schema_fields
    @manifest.manifest_schema['properties'].select{|prop| prop['required'] == true}
  end

export const allRequiredFields = (providedProps) => {
  return Object.keys(providedProps.schema.properties).filter((prop) => {
    return providedProps.schema.properties[prop].required === true
  })
}
export const allMatchedFields = (providedProps) => {
  return Array.from(new Set(providedProps.mapping.matched.map(obj => obj.expected)))
}
export const allRequiredUnmatchedFields = (providedProps) => {
  const matchedFields = new Set(allMatchedFields(providedProps))
  return (allRequiredFields(providedProps).filter(elem => !matchedFields.has(elem)))
}
export const isThereAnyRequiredUnmatchedField = (providedProps) => {
  if (!providedProps.schema) {
    return true
  }
  return (allRequiredUnmatchedFields(providedProps).length > 0)
}

  end

  def build_mapping
    @mapping = expected_keys_and_properties.reduce({
      observed: observed_keys.dup,
      expected: [],
      matched: []
    }) do |memo, expected_key_and_properties|
      expected_key, expected_properties = expected_key_and_properties
      if ((expected_properties['required']) || (expected_properties['show_on_form'] && expected_properties['field_name_regex']))
        found = observed_keys.detect do |observed_key|
          observed_key.strip.match(expected_properties['field_name_regex'])
        end
        if found
          memo[:matched].push({expected: expected_key, observed: found})
          memo[:observed].reject! { |observed_key| (observed_key == found) }
        else
          memo[:expected].push(expected_key)
        end
      end
      memo
    end
  end

  def save_mapped_contents(contents)
    if @mapping[:valid]
      @results = ProvenanceService.new(@manifest.manifest_schema).set_biomaterial_data(@manifest, contents, @user)
    end
  end

  def build_state_content(results)
    return {}
  end

  def build_state
    {
      manifest: {
        id: @manifest.id,
        schema: @manifest.manifest_schema,
        content: build_state_content(@results),
        mapping: @mapping
      }
    }
  end

  def build_keys(obj, keys)
    keys.reduce(obj) do |memo, key|
      memo[key]={} if !memo[key]
      memo[key]
    end
    obj
  end

  def mapped_array_params(array)
    array.reduce({}) do |memo, row|
      labware_id = row[@manifest.manifest_schema_field(:labware_id)]
      position = row[@manifest.manifest_schema_field(:position)]
      build_keys(memo, [:labwares, labware_id, :addresses, position])
      memo[:labwares][labware_id][:addresses][position] = mapped_row(row)
      memo
    end
  end

  def mapped_labware_params(contents)
    contents[:labwares].values.map do |labware|
      labware[:addresses]
    end
  end

  def mapped_row(row)
    row.keys.reduce({}) do |memo, key|
      memo[expected_matched_for_observed(key)] = row[key]
      memo
    end
  end

  def expected_matched_for_observed(key)
    @mapping[:matched].select{|match| match[:observed] == key }.first
  end



end
