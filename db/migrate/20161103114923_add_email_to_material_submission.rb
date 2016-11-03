class AddEmailToMaterialSubmission < ActiveRecord::Migration[5.0]
  def change
    add_column :material_submissions, :email, :string
  end
end
