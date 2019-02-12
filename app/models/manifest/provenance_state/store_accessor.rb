class Manifest::ProvenanceState::StoreAccessor < Manifest::ProvenanceState::Accessor
  delegate :manifest_schema, to: :provenance_state
  delegate :apply_messages, to: :provenance_state
  delegate :user, to: :provenance_state
  delegate :manifest_model, to: :provenance_state

  def rebuild?
    state_access && state_access[:structured] && state_access[:structured][:labwares]
  end

  def build
    update(updates_for(state_access[:structured][:labwares]))
    state_access
  end

  def updates_for(obj)
    return [] if obj.nil?
    obj.keys.reduce({}) do |memo_labware, labware_key|
      if obj[labware_key][:addresses]
        memo_labware[labware_key.to_s] = {
          "contents" =>  obj[labware_key][:addresses].keys.reduce({}) do |memo_address, address_key|
            memo_address[address_key] = obj[labware_key][:addresses][address_key][:fields].keys.reduce({}) do |memo_fields, field_key|
              memo_fields[field_key] = obj[labware_key][:addresses][address_key][:fields][field_key][:value]
              memo_fields
            end
            memo_address
          end
        }
      end
      memo_labware
    end
  end

  def update(updates)
    ActiveRecord::Base.transaction do
      if updates && !updates.empty?
        provenance = ProvenanceService.new(manifest_schema)
        success, errors, warnings = provenance.set_biomaterial_data(manifest_model, updates, user)
        apply_messages(errors, warnings)
        if success
          success = manifest_model.update_attributes(
            status: (manifest_model&.any_human_material_no_hmdmc? ? 'ethics' : 'dispatch')
          )
        end

        if (!success &&
            (manifest_model.status == 'dispatch' || manifest_model.status == 'ethics'))
          # If the given provenance is incomplete or wrong, make sure they're not in a later step
          #   (because they could have gone back and incorrected the material data).
          manifest_model.update_attributes(status: :provenance)
        end
        state_access[:update_successful] = success
      end
    end
  end

end
