class CreateLabwares < ActiveRecord::Migration[5.0]
  def change
    create_table :labwares do |t|
      t.references :labware_type, foreign_key: true
      t.string :type

      t.timestamps
    end
  end
end
