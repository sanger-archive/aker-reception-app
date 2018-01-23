# frozen_string_literal: true

module DispatchSteps
  # Step to create materials via MatconClient
  class CreateMaterialsStep
    def initialize(material_submission)
      @material_submission = material_submission
    end

    # If you're trying to be safe, you need to make sure errors from this method are caught.
    def up
      @material_submission.labwares.each do |labware|
        changed = false
        contents = labware.contents
        contents.each_value do |bio_data|
          next if bio_data['id']
          # The 'contact' for a siubmission has most recently been renamed to 'Sample Guardian'
          # while the 'owner_email' refers to the owner of the submission. Within materials, the
          # 'owner_email' is used as the 'submitter_id' indicating who submitted the materials and
          # the submission 'contact'/'Sample Guardian' is the 'owner' of the material(s).
          m = MatconClient::Material.create(bio_data.merge(
                                              owner_id: @material_submission.contact.email,
                                              submitter_id: @material_submission.owner_email
          ))
          bio_data['id'] = m.id
          changed = true
        end
        changed && labware.update_attributes(contents: contents)
      end
    end

    # If you're trying to be safe, you need to make sure errors from this method are caught.
    def down
      @material_submission.labwares.each do |labware|
        changed = false
        contents = labware.contents
        contents.each_value do |bio_data|
          next unless bio_data['id']
          MatconClient::Material.destroy(bio_data['id'])
          bio_data.delete('id')
          changed = true
        end
        changed && labware.update_attributes(contents: contents)
      end
    end
  end
end
