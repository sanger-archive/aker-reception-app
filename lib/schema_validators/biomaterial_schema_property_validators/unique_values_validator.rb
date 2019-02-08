module SchemaValidators
  module BiomaterialSchemaPropertyValidators
    class UniqueValuesValidator < BiomaterialSchemaPropertyValidator
      # This validator is needs to be initialized in every group of validations
      # related. In our case we initialize it every time we use the ProvenanceService
      def self.is_applicable?(property_name, property_data)
        property_data['unique_value'] == true
      end

      def location_display(duplicate_obj)
        "labware at tab #{duplicate_obj[:labware_index]+1} and address: #{duplicate_obj[:address]}"
      end

      def add_warning_for_duplication(ref1, ref2, dups)
        add_warning(ref1[:labware_index], ref1[:address], ref1[:property_name],
          "The field #{ref1[:property_name]} at #{ref1[:address]} has #{dups.length} duplicates for #{ref1[:value]} (eg: "+
            location_display(ref2)+")")
      end

      def validate(labware_index, address, bio_data)
        return true if field_data(bio_data).nil?
        success = true

        value = field_data(bio_data)
        prepare_memoized_values(labware_index, property_name)
        if is_duplicated?(labware_index, property_name, value)
          dups = duplicates(labware_index, property_name, value)

          chosen_duplicate = dups.first
          myself = {labware_index: labware_index, address: address, property_name: property_name, value: value}
          add_warning_for_duplication(myself, chosen_duplicate, dups)
          add_warning_for_duplication(chosen_duplicate, myself, dups)

          success = true
        else
          add_memoized_value(labware_index, address, property_name, value)
        end

        success
      end

      private
      def prepare_memoized_values(labware_index, property_name)
        @memoized_values = {} if @memoized_values.nil?
        @memoized_values[property_name] = [] unless @memoized_values[property_name]
      end

      def add_memoized_value(labware_index, address, property_name, value)
        @memoized_values[property_name].push({labware_index: labware_index, address: address, property_name: property_name, value: value})
      end

      def duplicates(labware_index, property_name, value)
        @memoized_values[property_name].select{|m| m[:value]==value}
      end

      def is_duplicated?(labware_index, property_name, value)
        @memoized_values[property_name].pluck(:value).include?(value)
      end

    end
  end
end
