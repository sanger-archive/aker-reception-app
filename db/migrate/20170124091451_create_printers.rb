class CreatePrinters < ActiveRecord::Migration[5.0]
  def change
    create_table :printers do |t|
      t.string :name
      t.string :label_type

      t.timestamps
    end
    add_index :printers, :name, unique: true
  end
end
