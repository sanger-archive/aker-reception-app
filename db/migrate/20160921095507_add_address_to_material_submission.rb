class AddAddressToMaterialSubmission < ActiveRecord::Migration[5.0]
  def change
    add_column :material_submissions, :address, :text
  end
end
