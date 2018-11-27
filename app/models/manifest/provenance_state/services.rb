class Manifest::ProvenanceState::Services < Manifest::ProvenanceState::Accessor
  def apply(state = nil)
    @state = state if state
    _build_content
  end

  def valid?
    true
  end

  private

  def _build_content
    @state[:services] = {} unless @state[:services]
    @state[:services][:taxonomy_service_url] = Rails.configuration.taxonomy_service_url
    @state[:services][:materials_schema_url] = Rails.configuration.material_url
    @state
  end

  Rails.configuration.taxonomy_service_url
end
