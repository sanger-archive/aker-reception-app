class DropOldTables < ActiveRecord::Migration[5.0]
  def change
    drop_table :wells
    drop_table :biomaterials
    drop_table :labwares
    drop_table :material_submission_labwares
  end
end
