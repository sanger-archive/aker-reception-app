require 'set'

module ManifestHelper
  def wells_attributes_for(plate)
    plate.wells.each_with_index.reduce({}) do |memo, list|
      well,index = list[0],list[1]
      memo[index.to_s] = {
        #id: well.id.to_s,
        position: well.address,
        biomaterial_attributes: well.biomaterial_id.nil? ? Biomaterial.new : Biomaterial.find(well.biomaterial_id)
      }
      memo
    end
  end

  def plate_attributes_for(labwares)
    mlabware = {}
    labwares.each_with_index do |plate, plate_idx|
      mlabware[plate_idx.to_s] = {
        id: plate.id.to_s,
        barcode: plate.barcode,
        wells_attributes: wells_attributes_for(plate)
      }
    end
    mlabware
  end

  def list_contents_keys(labwares)
    keys = Set.new()
    labwares.each do |labware|
      if labware.contents
        labware.contents.each do |address, bio_data|
          bio_data.each do |key, value|
            keys.add(key)
          end
        end
      end
    end
    return keys
  end

  def supply_labwares_desc(manifest)
    return '(Not selected)' if manifest.supply_labwares.nil?
    return 'No' unless manifest.supply_labwares
    return 'Yes' unless manifest.supply_decappers
    return 'Yes with decappers'
  end

  def supply_labware_type(manifest)
    return "Label for #{manifest.labware_type.name}" unless manifest.supply_labwares?
    return manifest.labware_type.name + ' with decappers' if manifest.supply_decappers?
    return manifest.labware_type.name
  end

  def state_for_manifest(manifest, user)
    Manifest::ProvenanceState.new(manifest, user).apply({})
    # {
    #   manifest: {
    #     manifest_id: manifest.id,
    #     labwares: labwares.map{|l| }
    #   },
    #   content: content_for_manifest(manifest),
    #   schema: manifest.schema
    # }
  end

  def content_for_manifest(manifest)
    manifest.labwares
  end

end
