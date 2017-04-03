class RemoveEmailFromMaterialSubmissions < ActiveRecord::Migration[5.0]
  def change
    remove_column :material_submissions, :email, :string
  end
end
