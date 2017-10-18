class AddDecapperColumns < ActiveRecord::Migration[5.0]
  def change
    add_column :labware_types, :uses_decapper, :boolean, null: false, default: false
    add_column :material_submissions, :supply_decappers, :boolean, null: false, default: false
  end
end
