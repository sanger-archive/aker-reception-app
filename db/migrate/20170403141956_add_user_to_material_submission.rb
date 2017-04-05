class AddUserToMaterialSubmission < ActiveRecord::Migration[5.0]
  def change
  	 add_column :material_submissions, :user_id, :integer
  end
end
