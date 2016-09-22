class CreateMaterialSubmissionLabwares < ActiveRecord::Migration[5.0]
  def change
    create_table :material_submission_labwares do |t|
      t.references :material_submission, foreign_key: true
      t.references :labware, foreign_key: true

      t.timestamps
    end
  end
end
