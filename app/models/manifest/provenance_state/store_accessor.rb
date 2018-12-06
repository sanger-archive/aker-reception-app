class Manifest::ProvenanceState::StoreAccessor < Manifest::ProvenanceState::Accessor
  delegate :manifest_schema, to: :provenance_state
  delegate :user, to: :provenance_state
  delegate :manifest_model, to: :provenance_state

  def rebuild?
    true
  end

  def build
    update(updates_for(state_access[:structured][:labwares]))
    state_access
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
      provenance = ProvenanceService.new(manifest_schema)
      success, messages = provenance.set_biomaterial_data(manifest_model, updates, user)
      apply_messages(messages)
    end
  end

  def add_message(labware_index, address, field, text)
    state_access[:structured][:messages] = [] unless state_access[:structured][:messages]
    state_access[:structured][:messages].push({level: "ERROR",
      text: text, labware_index: labware_index, address: address, field: field
      })
    if labware_index && address && field
      build_keys(@state, [:content, :structured, :labwares, labware_index, :addresses, address, :fields, field, :messages])
      state_access[:structured][:labwares][labware_index][:addresses][address][:fields][field][:messages] = [text]
    end
  end

  def clean_errors
    if state_access[:structured]
      state_access[:structured][:messages] = []
      state_access[:structured][:labwares].keys.each do |l_key|
        state_access[:structured][:labwares][l_key][:addresses].keys.each do |a_key|
          state_access[:structured][:labwares][l_key][:addresses][a_key][:fields].keys.each do |f_key|
            state_access[:structured][:labwares][l_key][:addresses][a_key][:fields][f_key][:messages] = []
          end
        end
      end
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
