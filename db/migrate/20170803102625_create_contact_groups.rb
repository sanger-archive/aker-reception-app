class CreateContactGroups < ActiveRecord::Migration[5.0]
  def change
    create_table :contact_groups do |t|
      t.string :name, null: false

      t.timestamps
    end
    add_index :contact_groups, :name, unique: true
  end
end
