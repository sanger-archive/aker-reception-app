class AddRemoveCascadeForMaterialSubmissionLabwares < ActiveRecord::Migration[5.0]
  def change
    remove_foreign_key :labwares, :material_submissions
    add_foreign_key :labwares, :material_submissions, on_delete: :cascade
  end
end
