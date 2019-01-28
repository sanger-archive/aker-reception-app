class Manifest::ProvenanceState::StoreAccessor < Manifest::ProvenanceState::Accessor
  delegate :manifest_schema, to: :provenance_state
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
        success, messages = provenance.set_biomaterial_data(manifest_model, updates, user)
        apply_messages(messages)

        if success #&& !params["manifest"]["change_tab"]
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

  def add_message(labware_index, address, field, text)
    state_access[:structured][:messages] = [] unless state_access[:structured][:messages]
    state_access[:structured][:messages].push({level: "ERROR",
      text: text, labware_index: labware_index, address: address, field: field
      })
    #if labware_index && address && field
    #  build_keys(@state, [:content, :structured, :labwares, labware_index, :addresses, address, :fields, field, :messages])
    #  state_access[:structured][:labwares][labware_index][:addresses][address][:fields][field][:messages] = [text]
    #end
  end

  def clean_errors
    if state_access[:structured]
      state_access[:structured][:messages] = []
      # state_access[:structured][:labwares].keys.each do |l_key|
      #   if state_access[:structured][:labwares][l_key][:addresses]
      #     state_access[:structured][:labwares][l_key][:addresses].keys.each do |a_key|
      #       state_access[:structured][:labwares][l_key][:addresses][a_key][:fields].keys.each do |f_key|
      #         state_access[:structured][:labwares][l_key][:addresses][a_key][:fields][f_key][:messages] = []
      #       end
      #     end
      #   end
      # end
    end
  end

  def apply_messages(messages)
    clean_errors
    messages.each do |message|
      message[:errors].keys.each do |field|
        add_message(message[:labwareIndex].to_s, message[:address], field, message[:errors][field])
      end
    end
  end

end
