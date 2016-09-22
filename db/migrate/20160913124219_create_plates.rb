class CreatePlates < ActiveRecord::Migration[5.0]
  def change
    create_table :plates do |t|
      t.references :labware_type, foreign_key: true

      t.timestamps
    end
  end
end
