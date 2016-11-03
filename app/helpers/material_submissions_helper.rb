module MaterialSubmissionsHelper
def wells_attributes_for(plate)
  plate.wells.each_with_index.reduce({}) do |memo, list|
    well,index = list[0],list[1]
    memo[index.to_s] = {
      :id => well.id.to_s,
      :position => well.position,
      :biomaterial_attributes => (well.biomaterial || Biomaterial.new)
    }
    memo
  end
end

def plate_attributes_for(labwares)
  mlabware = {}
  labwares.each_with_index do |plate, plate_idx|
    mlabware[plate_idx.to_s] = {
      :id => plate.id.to_s,
      :barcode => plate.barcode,
      :wells_attributes => wells_attributes_for(plate)
    }
  end
  mlabware
end


end
