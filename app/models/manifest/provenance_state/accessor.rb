# Set of generic functions to access and update each part of the provenance
# state object
class Manifest::ProvenanceState::Accessor
  class StopApplying < StandardError ; end
  # Given a provenance state and a key, builds a manager object to perform
  # accesses and updates only on this part of the state
  def initialize(provenance_state, key)
    @provenance_state = provenance_state
    @state = provenance_state.state
    @key = key
  end

  # Updates current provenance state section with the state provided
  def apply(state=nil)
    @state = state if state
    @state[@key] = build if rebuild?
    validate if present?
  end

  # True if the current state contains the key for the section it manages
  def present?
    @state.key?(@key) && (@state[@key].keys.length > 0)
  end

  # Current section of the state (referred by the key at initialization)
  def state_access
    @state[@key]
  end

  # True if we have to recreate this part of the provenance state
  def rebuild?
    !present?
  end

  # Perform a validation process in this part of the provenance state
  def validate
  end

  # Allocates memory for the list of keys provided inside the hash obj
  def build_keys(obj, list, value=nil)
    obj = list.reduce(obj) do |memo, key|
      (memo[key] || (memo[key] = {}))
    end
    obj = value if value
    obj
  end

  def add_message(level, labware_index, address, field, text)
    state_access[:structured] = { messages: [] } if state_access[:structured].nil?
    state_access[:structured][:messages] = [] unless state_access[:structured][:messages]
    state_access[:structured][:messages].push({level: level,
      text: text, labware_index: labware_index, address: address, field: field
      })
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
        add_message("ERROR", message[:labwareIndex].to_s, message[:address], field, message[:errors][field])
      end
    end
    warnings.each do |message|
      message[:warnings].keys.each do |field|
        add_message("WARNING", message[:labwareIndex].to_s, message[:address], field, message[:warnings][field])
      end
    end

  end

  def fail_with_error(msg)
    clean_messages
    add_message("ERROR", nil, nil, nil, msg)
    state_access[:valid] = false
    raise StopApplying
  end




  attr_reader :provenance_state, :state
end
