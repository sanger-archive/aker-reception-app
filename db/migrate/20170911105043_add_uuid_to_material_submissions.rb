class AddUuidToMaterialSubmissions < ActiveRecord::Migration[5.0]
  def up
    add_column :material_submissions, :material_submission_uuid, :string

    # add a UUID for all existing submissions
    MaterialSubmission.find_each do |submission|
      submission.material_submission_uuid = SecureRandom.uuid
      submission.save!
    end
  end

  def down
    remove_column :material_submissions, :material_submission_uuid, :string
  end
end
