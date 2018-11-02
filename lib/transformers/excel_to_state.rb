module Transformers
  class ExcelToState < ExcelToArray

    def mapping_tool
      expected_keys_and_properties.reduce({
        observed: observed_keys.dup, expected: [], matched: []
      }) do |memo, expected_key_and_properties|
        expected_key, expected_properties = expected_key_and_properties
        if expected_properties['show_on_form'] && expected_properties['field_name_regex']
          found = observed_keys.detect do |observed_key|
            observed_key.strip.match(expected_properties['field_name_regex'])
          end
          if found
            memo[:matched].push({observed: found, expected: expected_key })
            memo[:observed].reject! { |observed_key| (observed_key == found) }
          else
            memo[:expected].push(expected_key)
          end
        end
        memo
      end
    end

    def contents
      {
        manifest: manifest,
        mapping_tool: mapping_tool
      }
    end

    def manifest
      @contents
    end

    private

    def observed_keys
      return manifest.first.keys.map(&:to_s) if manifest.length > 0
      []
    end

    def expected_keys_and_properties
      schema['properties'].each_pair.select do |expected_key, expected_properties|
        (expected_properties['show_on_form'] && expected_properties['field_name_regex'])
      end.map{|k,v| [k.to_s, v]}
    end

    def schema
      MatconClient::Material.schema
    end
  end
end
