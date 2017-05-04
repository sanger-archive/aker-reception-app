class CreateSetsStep
  def initialize(material_submission)
    @material_submission = material_submission
  end

  # If you're trying to be safe, you need to make sure errors from this method are caught.
  def up
    unless @material_submission.set_id
      set = SetClient::Set.create(name: "Submission #{@material_submission.id}", owner_id: @material_submission.contact.email)
      @material_submission.update_attributes(set_id: set.id)

      # Adding materials to set
      # set_materials takes an array of uuids
      uuids=[]
      @material_submission.labwares.each do | labware |
        labware.contents.each do | address, bio_data |
          uuids.push(bio_data['id'])
        end
      end
      set.set_materials(uuids)
      set.update_attributes(locked: true)
    end
  end

  # If you're trying to be safe, you need to make sure errors from this method are caught.
  def down
    if @material_submission.set_id
      SetClient::Set.find(@material_submission.set_id).first.destroy
      @material_submission.update_attributes(set_id: nil)
    end
  end
end
