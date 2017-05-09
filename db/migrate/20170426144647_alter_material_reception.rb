class AlterMaterialReception < ActiveRecord::Migration[5.0]
  def change
    remove_column :material_receptions, :labware_id
    add_column :material_receptions, :labware_id, :integer, null: false

    add_index :material_receptions, :labware_id, unique: true
    add_foreign_key :material_receptions, :labwares
  end
end
