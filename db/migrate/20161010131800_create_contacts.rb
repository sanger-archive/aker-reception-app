class CreateContacts < ActiveRecord::Migration[5.0]
  def change
    create_table :contacts do |t|
      t.string :fullname
      t.string :email
      t.timestamps
    end

    add_reference :material_submissions, :contact, :index => true, foreign_key: true
  end
end
