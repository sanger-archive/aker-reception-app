module DispatchSteps
  class CreateSetsStep
    def initialize(manifest)
      @manifest = manifest
    end

    # If you're trying to be safe, you need to make sure errors from this method are caught.
    def up
      unless @manifest.set_id
        set = SetClient::Set.create(name: "Manifest #{@manifest.id}")
        @manifest.update_attributes(set_id: set.id)

        # Adding materials to set
        # set_materials takes an array of uuids
        uuids = @manifest.labwares.flat_map { |lw| lw.contents.values }.flat_map { |c| c['id'] }

        set.set_materials(uuids)

        # IMPORTANT!!
        # A Set cannot be updated or removed anymore if you are not the owner of it, so
        # after giving an owner to the set, I won't be able to destroy it
        set.update_attributes(locked: true, owner_id: @manifest.owner_email)
      end
    end

    # If you're trying to be safe, you need to make sure errors from this method are caught.
    def down
      if @manifest.set_id
        SetClient::Set.find(@manifest.set_id).first.destroy
        @manifest.update_attributes(set_id: nil)
      end
    end
  end
end
