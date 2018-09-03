module DispatchSteps
  class CreateSetsStep
    def initialize(material_submission)
      @material_submission = material_submission
    end

    # If you're trying to be safe, you need to make sure errors from this method are caught.
    def up
      unless @material_submission.set_id
        set = SetClient::Set.create(name: "Manifest #{@material_submission.id}")
        @material_submission.update_attributes(set_id: set.id)

        # Adding materials to set
        # set_materials takes an array of uuids
        uuids = @material_submission.labwares.flat_map { |lw| lw.contents.values }.flat_map { |c| c['id'] }

        set.set_materials(uuids)

        # IMPORTANT!!
        # A Set cannot be updated or removed anymore if you are not the owner of it, so
        # after giving an owner to the set, I won't be able to destroy it
        set.update_attributes(locked: true, owner_id: @material_submission.owner_email)
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
end
