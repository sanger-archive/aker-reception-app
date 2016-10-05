class CreateWells < ActiveRecord::Migration[5.0]
  def change
    create_table :wells do |t|
      t.references :labware, foreign_key: true
      t.string :position

      t.timestamps
    end
  end
end
