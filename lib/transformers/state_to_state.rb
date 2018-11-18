module Transformers
  class StateToState
    def initialize(options)
      @provenance_state = Manifest::ProvenanceState.new(options.fetch(:manifest_model), options.fetch(:current_user))
      @state = options.fetch(:state)
    end

    def transform
      @provenance_state.apply(@state)
    end

    def contents
      @provenance_state.state
    end
  end
end
