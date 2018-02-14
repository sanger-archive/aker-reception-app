class DropUsersTable < ActiveRecord::Migration[5.0]
  def change
    add_column :material_submissions, :owner_email, :string

    remove_column :material_submissions, :user_id
    drop_table :users

    add_index :material_submissions, :owner_email
  end
end