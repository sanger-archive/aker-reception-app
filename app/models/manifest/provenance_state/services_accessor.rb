class Manifest::ProvenanceState::ServicesAccessor < Manifest::ProvenanceState::Accessor

  def build
    {
      taxonomy_service_url: Rails.configuration.taxonomy_service_url,
      materials_schema_url: Rails.configuration.material_url
    }
  end

  def validate
    @state[@key][:valid] = true
  end


end
