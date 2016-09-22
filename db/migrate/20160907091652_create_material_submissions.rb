class CreateMaterialSubmissions < ActiveRecord::Migration[5.0]
  def change
    create_table :material_submissions do |t|
      t.integer :no_of_labwares_required
      t.boolean :supply_labwares
      t.references :labware_type, foreign_key: true
      t.string :status

      t.timestamps
    end
  end
end
