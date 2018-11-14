module Transformers
  class StateToState
    def initialize(state)
      @mapping_service = MappingService.new(options.fetch(:manifest_model), options.fetch(:current_user))
      @state = options.fetch(:state)
    end

    def contents
      @mapping_service.process_state(@state)
    end
  end
end
