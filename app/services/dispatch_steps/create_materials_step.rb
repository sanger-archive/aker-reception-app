# frozen_string_literal: true

module DispatchSteps
  # Step to create materials via MatconClient
  class CreateMaterialsStep
    def initialize(manifest)
      @manifest = manifest
    end

    def valid_bio_data(bio_data)
      config = Rails.application.config.manifest_schema_config
      bio_data.reject do |k|
        (k==config["field_labware_name"]) || (k==config["field_position"]) || (k=='plate_id')
      end
    end

    # If you're trying to be safe, you need to make sure errors from this method are caught.
    def up
      @manifest.labwares.each do |labware|
        changed = false
        contents = labware.contents
        contents.each_value do |bio_data|
          next if bio_data['id']
          # The 'contact' for a manifest has most recently been renamed to 'Sample Guardian'
          # while the 'owner_email' refers to the creator of the manifest. Within materials, the
          # 'owner_email' is used as the 'submitter_id' indicating who submitted the materials and
          # the manifest 'contact'/'Sample Guardian' is the 'owner' of the material(s).
          m = MatconClient::Material.create(valid_bio_data(bio_data).merge(
                                              owner_id: @manifest.contact.email,
                                              submitter_id: @manifest.owner_email
          ))
          bio_data['id'] = m.id
          changed = true
        end
        changed && labware.update_attributes(contents: contents)
      end
    end

    # If you're trying to be safe, you need to make sure errors from this method are caught.
    def down
      @manifest.labwares.each do |labware|
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
