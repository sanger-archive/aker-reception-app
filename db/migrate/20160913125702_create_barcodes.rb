class CreateBarcodes < ActiveRecord::Migration[5.0]
  def change
    create_table :barcodes do |t|
      t.string :barcode_type
      t.string :value
      t.references :barcodeable, polymorphic: true

      t.timestamps
    end
  end
end
