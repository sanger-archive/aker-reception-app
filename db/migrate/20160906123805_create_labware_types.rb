class CreateLabwareTypes < ActiveRecord::Migration[5.0]
  def change
    create_table :labware_types do |t|
      t.integer :x_dimension_size
      t.integer :y_dimension_size
      t.boolean :x_dimension_is_alpha
      t.boolean :y_dimension_is_alpha
      t.string :name
      t.string :description

      t.timestamps
    end
  end
end
