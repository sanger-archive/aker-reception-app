module Transformers
  class StateToState
    attr_reader :errors
    def initialize(options)
      @errors = ActiveModel::Errors.new(self)
      @provenance_state = Manifest::ProvenanceState.new(options.fetch(:manifest_model), options.fetch(:current_user))
      @state = options.fetch(:state)
    end

    def transform
      begin
        @provenance_state.apply(@state)
        return true
      rescue StandardError => e
        errors.add(:base, e)
      end
      false
    end

    def contents
      @provenance_state.state
    end
  end
end
