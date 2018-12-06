class Manifest::ProvenanceState::ManifestAccessor < Manifest::ProvenanceState::Accessor

  def manifest_model
    @provenance_state.manifest_model
  end

  def build
    {
      manifest_id: manifest_model.id,
      selectedTabPosition: 0,
      labwares: labwares
    }
  end

  def labwares
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
