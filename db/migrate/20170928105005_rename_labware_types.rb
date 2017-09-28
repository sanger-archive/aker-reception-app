class RenameLabwareTypes < ActiveRecord::Migration[5.0]
  def change
    # This migration will not explode if the labware types do not exist
    name_changes = {
      'ABgene AB_0800' => 'ABgene AB-0800 shallow well PCR plate',
      'ABgene AB_0859' => 'ABgene AB-0859 deep well plate',
      '1.5ml' => 'Eppendorf 2.0ml tube',
    }
    name_changes.each do |old_name, new_name|
      lt = LabwareType.find_by(name: old_name)
      if lt
        lt.update_attributes(name: new_name)
      end
    end
    fluidx = LabwareType.find_by(name: 'FluidX 0.75ml')
    if fluidx
      plate = LabwareType.find_by(name: 'ABgene AB-0800 shallow well PCR plate')
      MaterialSubmission.where(labware_type_id: fluidx.id).update_all(labware_type_id: plate.id)
      fluidx.destroy
    end
  end
end
