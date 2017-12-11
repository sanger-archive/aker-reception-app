class AddNameIndexes < ActiveRecord::Migration[5.0]
  def change
    add_index :label_templates, :name, unique: true
    add_index :labware_types, :name, unique: true
  end
end
