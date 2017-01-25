class CreateMaterialReceptions < ActiveRecord::Migration[5.0]
  def change
    create_table :material_receptions do |t|
      t.references :labware, foreign_key: true
      t.timestamps
    end
  end
end
