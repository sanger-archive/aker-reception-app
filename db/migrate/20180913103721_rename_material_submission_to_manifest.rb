class RenameMaterialSubmissionToManifest < ActiveRecord::Migration[5.2]
  def change
    rename_column :material_submissions, :material_submission_uuid, :manifest_uuid
    rename_table :material_submissions, :manifests
    rename_column :labwares, :material_submission_id, :manifest_id
  end
end
