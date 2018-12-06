class Manifest::ProvenanceState::Accessor

  def initialize(provenance_state, key)
    @provenance_state = provenance_state
    @state = provenance_state.state
    @key = key
  end

  def apply(state=nil)
    @state = state if state
    @state[@key] = build if rebuild?
    validate if present?
  end

  def present?
    @state.key?(@key) && (@state[@key].keys.length > 0)
  end

  def state_access
    @state[@key]
  end

  def rebuild?
    !present?
  end

  def validate
    @state[@key][:valid] = true
  end

  def build_keys(obj, list, value=nil)
    obj = list.reduce(obj) do |memo, e|
      memo[e]={} unless memo[e]
      memo[e]
    end
    obj = value if value
    obj
  end

  attr_reader :provenance_state, :state
end
