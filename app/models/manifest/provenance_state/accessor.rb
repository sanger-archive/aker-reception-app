# Set of generic functions to access and update each part of the provenance
# state object
class Manifest::ProvenanceState::Accessor
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


  attr_reader :provenance_state, :state
end
