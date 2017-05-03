class SetService

  attr_reader :material_submission

  def initialize(material_submission)
    @material_submission = material_submission
  end

  def up
    materials = []
    material_submission.labwares.each do |lw|
      lw.wells.each do |well|
        materials.append(well.biomaterial) unless well.biomaterial.nil?
      end
    end

    # Creation of set
    new_set = SetClient::Set.create(name: "Submission #{material_submission.id}", owner_id: material_submission.contact.email)

    # Adding materials to set
    # set_materials takes an array of uuids
    new_set.set_materials(materials.compact.map(&:uuid))
    new_set.update_attributes(locked: true)
  end

  def down

  end
  
end