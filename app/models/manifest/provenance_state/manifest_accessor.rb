class Manifest::ProvenanceState::ManifestAccessor < Manifest::ProvenanceState::Accessor
  def apply(state = nil)
    @state = state if state
    _build_manifest
    validate
    @state
  end

  def manifest_model
    @provenance_state.manifest_model
  end

  def validate
  end

  def valid?
    true
  end

  def labwares
    if @state && @state[:manifest] && @state[:manifest][:labwares]
      @state[:manifest][:labwares]
    else
      []
    end
  end

  private

  def _build_manifest
    @state[:manifest] = {
      manifest_id: manifest_model.id,
      labwares: _labwares
    }
  end

  def _labwares
    manifest_model.labwares.each_with_index.map do |labware, idx|
      labware_index = idx+1
      supplier_plate_name = labware.supplier_plate_name
      supplier_plate_name = "Labware #{labware_index}" if supplier_plate_name.nil? || supplier_plate_name.empty?
      {
        labware_index: labware_index.to_s,
        positions: labware.positions,
        supplier_plate_name: supplier_plate_name
      }
    end
  end

end
