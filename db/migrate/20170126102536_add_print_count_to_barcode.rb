class AddPrintCountToBarcode < ActiveRecord::Migration[5.0]
  def change
    add_column :barcodes, :print_count, :int, :null => false, :default => 0
  end
end
