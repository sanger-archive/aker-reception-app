class Manifest::ProvenanceState::Accessor

  def initialize(provenance_state)
    @provenance_state = provenance_state
    @state = provenance_state.state
  end

  def apply(state=nil)
    @state = state if state
  end

  attr_reader :provenance_state, :state
end
