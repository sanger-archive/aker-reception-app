module Transformers
  class ExcelToState < ExcelToArray
    def initialize(options)
      super(options)
      @manifest_model = options.fetch(:manifest_model)
    end

    def contents
      {
        manifest: {
          id: manifest_id,
          schema: manifest_schema,
          content: manifest_content,
          mapping: mapping_data
        }
      }
    end

    def manifest_id
      @manifest_model.id
    end

    def manifest_content
      @contents
    end

    def manifest_schema
      @manifest_model.manifest_schema
    end

    def mapping_data
      build_mapping_data
    end

    private

    # def add_shown_to_mapping_data(data)
    #   all_required_fields = manifest_schema['properties'].select{|e| e['required']}
    #   all_matched_expected = data.map(&:matched).map(&:expected)

    #   data[:mapping].merge(shown: ((all_required_fields - all_matched_expected).count > 0))
    # end

    def build_mapping_data
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

    def expected_info(expected)
      data = manifest_schema['properties'][expected]
      {required: data['required']||false, friendly_name: data['friendly_name'], field_name: expected}
    end

    def observed_keys
      return manifest_content.first.keys.map(&:to_s) if manifest_content.length > 0
      []
    end

    def expected_keys_and_properties
      manifest_schema['properties'].each_pair.select do |expected_key, expected_properties|
        (expected_properties['required'] || (expected_properties['show_on_form'] && expected_properties['field_name_regex']))
      end.map{|k,v| [k.to_s, v]}
    end

  end
end
