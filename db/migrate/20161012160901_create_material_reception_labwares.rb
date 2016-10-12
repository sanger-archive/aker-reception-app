class CreateMaterialReceptionLabwares < ActiveRecord::Migration[5.0]
  def change
    create_table :material_reception_labwares do |t|

      t.timestamps
    end
  end
end
