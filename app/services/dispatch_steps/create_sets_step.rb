class CreateSetsStep
  def initialize(material_submission)
    @material_submission = material_submission
  end

  # If you're trying to be safe, you need to make sure errors from this method are caught.
  def up
    unless @material_submission.set_id
      set = SetClient::Set.create(name: "Submission #{@material_submission.id}", owner_id: @material_submission.contact.email)
      @material_submission.update_attributes(set_id: set.id)
      # TODO - add materials to set
    end
  end

  # If you're trying to be safe, you need to make sure errors from this method are caught.
  def down
    if @material_submission.set_id
      SetClient::Set.find(@material_submission.set_id).destroy
      @material_submission.update_attributes(set_id: nil)
    end
  end
end
