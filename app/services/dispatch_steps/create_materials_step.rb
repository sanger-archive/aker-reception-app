# Step to create materials via MatconClient
class CreateMaterialsStep

  def initialize(material_submission)
    @material_submission = material_submission
  end

  # If you're trying to be safe, you need to make sure errors from this method are caught.
  def up
    @material_submission.labwares.each do | labware |
      labware.contents.each do | address, bio_data |
        unless bio_data['id']
          m = MatconClient::Material.create(bio_data)
          bio_data['id'] = m.id
        end
      end
      labware.update_attributes(contents: labware.contents)
    end
  end

  # If you're trying to be safe, you need to make sure errors from this method are caught.
  def down
    @material_submission.labwares.each do | labware |
      labware.contents.each do | address, bio_data |
        if bio_data['id']
          MatconClient::Material.destroy(bio_data['id'])
          bio_data.delete('id')
        end
      end
      labware.update_attributes(contents: labware.contents)
    end
  end
end
