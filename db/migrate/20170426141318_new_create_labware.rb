class NewCreateLabware < ActiveRecord::Migration[5.0]
  def change
    create_table :labwares do |t|
      t.integer :material_submission_id, null: false
      t.integer :labware_index, null: false
      t.integer :print_count, null: false, default: 0

      t.jsonb :contents, null: true
      t.string :barcode, null: true
      t.string :container_id, null: true

      t.timestamps
    end

    add_foreign_key :labwares, :material_submissions
    add_index :labwares, [:material_submission_id, :labware_index], unique: true
    add_index :labwares, :barcode, unique: true
    add_index :labwares, :container_id, unique: true
  end
end
