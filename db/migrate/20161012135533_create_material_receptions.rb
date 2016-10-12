class CreateMaterialReceptions < ActiveRecord::Migration[5.0]
  def change
    create_table :material_receptions do |t|
      t.string :barcode
      t.timestamps
    end
  end
end
