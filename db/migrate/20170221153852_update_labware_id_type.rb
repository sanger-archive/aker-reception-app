class UpdateLabwareIdType < ActiveRecord::Migration[5.0]
  def change
    change_column :material_submission_labwares, :labware_id, :string
  end
end
