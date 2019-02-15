module Transformers
  class ExcelToState < ExcelToArray
    def initialize(options)
      super(options)
      @provenance_state = Manifest::ProvenanceState.new(options.fetch(:manifest_model), options.fetch(:current_user))
    end

    def transform
      begin
        return !!(super && @provenance_state.apply(build_state(@contents)))
      rescue StandardError => e
        errors.add(:base, e)
      end

      return false
    end

    def build_state(raw_content)
      {
        content: {
          raw: raw_content,
          rebuild: true
        },
        mapping: {
          rebuild: true
        }
      }
    end

    def contents
      @provenance_state.state
    end
  end
end
