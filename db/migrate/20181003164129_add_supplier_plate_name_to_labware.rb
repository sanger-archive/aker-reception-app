class AddSupplierPlateNameToLabware < ActiveRecord::Migration[5.2]
  def change
    add_column :labwares, :supplier_plate_name, :string
  end
end
