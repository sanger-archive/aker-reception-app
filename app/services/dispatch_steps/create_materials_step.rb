# Step to create materials via MatconClient
module DispatchSteps
  class CreateMaterialsStep

    def initialize(material_submission)
      @material_submission = material_submission
    end

    # If you're trying to be safe, you need to make sure errors from this method are caught.
    def up
      @material_submission.labwares.each do | labware |
        changed = false
        contents = labware.contents
        contents.each do | address, bio_data |
          unless bio_data['id']
            m = MatconClient::Material.create(bio_data.merge(owner_id: @material_submission.contact.email))
            bio_data['id'] = m.id
            changed = true
          end
        end
        if changed
          labware.update_attributes(contents: contents)
        end
      end
    end

    # If you're trying to be safe, you need to make sure errors from this method are caught.
    def down
      @material_submission.labwares.each do | labware |
        changed = false
        contents = labware.contents
        contents.each do | address, bio_data |
          if bio_data['id']
            MatconClient::Material.destroy(bio_data['id'])
            bio_data.delete('id')
            changed = true
          end
        end
        if changed
          labware.update_attributes(contents: contents)
        end
      end
    end
  end
end