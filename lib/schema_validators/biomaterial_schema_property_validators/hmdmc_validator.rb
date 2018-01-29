require 'ehmdmc_client'

module SchemaValidators
  module BiomaterialSchemaPropertyValidators
    class HmdmcValidator < BiomaterialSchemaPropertyValidator

      def self.is_applicable?(property_name, property_data)
        property_name == 'hmdmc'
      end

      # Performs some checks based on the presence of HMDMC
      def check_hmdmc(hmdmc_number, bio_data)
        return nil if field_data(bio_data).nil?
        # Only allow human material/samples to have HMDMC numbers
        # TODO: Change to taxon_id
        species = field_data_for_property('scientific_name', bio_data)
        unless species.present? && species.strip.downcase == 'homo sapiens'
          return 'Only human material are to have HMDMC numbers associated.'
        end
        # Check format validity
        unless hmdmc_number.match(/^[0-9]{2}\/[0-9]{3,4}$/)
          return 'The HMDMC number must be of the format ##/####.'
        end
        # Check the actual number with the HMDMC service
        validation = EHMDMCClient.validate_hmdmc(hmdmc_number)
        unless validation.valid?
          return validation.error_message
        end
      end


      def validate(labware_index, address, bio_data)
        # Check HMDMC server-side
        hmdmc_error = check_hmdmc(field_data(bio_data), bio_data)
        unless hmdmc_error.blank?
          add_error(labware_index,
                    address,
                    property_name,
                    hmdmc_error)
        end
      end
    end
  end
end