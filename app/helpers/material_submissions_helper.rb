require 'set'

module MaterialSubmissionsHelper
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

  def supply_labwares_desc(submission)
    return '(Not selected)' if submission.supply_labwares.nil?
    return 'No' unless submission.supply_labwares
    return 'Yes' unless submission.supply_decappers
    return 'Yes with decappers'
  end

  def supply_labware_type(submission)
    return "Label for #{submission.labware_type.name}" unless submission.supply_labwares?
    return submission.labware_type.name + ' with decappers' if submission.supply_decappers?
    return submission.labware_type.name
  end

end
