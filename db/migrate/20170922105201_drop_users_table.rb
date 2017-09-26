class DropUsersTable < ActiveRecord::Migration[5.0]
  def change
    add_column :material_submissions, :owner_email, :string

    MaterialSubmission.where.not(user_id: nil).each do |material_submission|
      material_submission.update_attributes(owner_email: User.find(material_submission.user_id).email)
    end
    remove_column :material_submissions, :user_id
    drop_table :users

    add_index :material_submissions, :owner_email
  end
end