class Manifest::ProvenanceState::Mapping < Manifest::ProvenanceState::Accessor
  delegate :manifest_schema, to: :provenance_state

  def apply(state = nil)
    @state = state if state
    _build_mapping
    unless (@state[:mapping].key?(:valid))
      @state[:mapping][:valid] = (required_unmatched_fields.length == 0)
    end
  end

  def valid?
    @state.key?(:mapping) && @state[:mapping].key?(:valid) && @state[:mapping][:valid]
  end

  private

  def _build_mapping
    unless @state[:mapping]
      if @state[:content][:raw]
        @state[:mapping] = _mapping_from_raw
      else
        @state[:mapping] = {valid: false}
      end
    end
  end

  def _mapping_from_raw
    expected_keys_and_properties.reduce({
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

  def observed_keys
    return @state[:content][:raw].first.keys.map(&:to_s) if @state[:content][:raw].length > 0
    []
  end

  def expected_field?(field_properties)
    field_properties['required'] || field_properties['show_on_form']
  end

  def expected_keys_and_properties
    manifest_schema['properties'].each_pair.select do |expected_key, field_properties|
      expected_field?(field_properties)
    end.map{|k,v| [k.to_s, v]}
  end

  def required_unmatched_fields
    required_schema_fields.select{|f| matched_expected_fields.include(f)}
  end

  def matched_expected_fields
    @state[:mapping][:matched].map{|m| m[:expected]}
  end

  def required_schema_fields
    manifest_schema['properties'].select{|prop| prop['required'] == true}
  end


end
