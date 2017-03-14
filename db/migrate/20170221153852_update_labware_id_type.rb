class UpdateLabwareIdType < ActiveRecord::Migration[5.0]
  def change
    ActiveRecord::Base.transaction do
      remove_foreign_key :material_submission_labwares, :labwares
      change_column :material_submission_labwares, :labware_id, :string
    end
  end
end
