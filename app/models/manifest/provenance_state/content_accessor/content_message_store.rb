module Manifest::ProvenanceState::ContentAccessor::ContentMessageStore
  def add_message(message)
    state_access[:structured] = { messages: [] } if state_access[:structured].nil?
    state_access[:structured][:messages] = [] unless state_access[:structured][:messages]
    if message.validate
      state_access[:structured][:messages].push(message.serialize)
      state_access[:valid] = false if (message.level=='ERROR')
    end
  end

  def clean_messages
    if state_access[:structured]
      state_access[:structured][:messages] = []
    end
  end

  def apply_messages(errors, warnings)
    clean_messages
    errors.each do |message|
      message[:errors].keys.each do |field|
        add_message(Manifest::ProvenanceState::ContentAccessor::ContentMessage.new(
          level: "ERROR", labware_index: message[:labwareIndex].to_s,
          address: message[:address], field: field, text: message[:errors][field]))
      end
    end
    warnings.each do |message|
      message[:warnings].keys.each do |field|
        add_message(Manifest::ProvenanceState::ContentAccessor::ContentMessage.new(
          level: "WARNING", labware_index: message[:labwareIndex].to_s, address: message[:address],
          field: field, text: message[:warnings][field]))
      end
    end
  end
end

