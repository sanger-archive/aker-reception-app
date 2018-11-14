class MappingService
  def initialize(manifest, user)
    @manifest = manifest
    @user = user
  end

  def process_array(array)
    @contents = array
    @mapping = parse_array
    save_mapped_contents(mapped_array_params(array))
    build_state
  end

  def process_state(state)
    @contents = state[:content]
    @mapping = state[:mapping]
    save_mapped_contents(mapped_labware_params(state[:content]))
    build_state
  end

  private

  def parse_array
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


  def observed_keys
    return @contents.first.keys.map(&:to_s) if @contents.length > 0
    []
  end

  def expected_keys_and_properties
    @manifest.manifest_schema['properties'].each_pair.select do |expected_key, expected_properties|
      (expected_properties['required'] || (expected_properties['show_on_form'] && expected_properties['field_name_regex']))
    end.map{|k,v| [k.to_s, v]}
  end

end
