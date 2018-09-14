class CreateLabelTemplates < ActiveRecord::Migration[5.0]
  def change
    create_table :label_templates do |t|
      t.string :name, null: false, unique: true
      t.string :template_type, null: true, unique: true
      t.integer :external_id, null: false, unique: true

      t.timestamps null: false
    end
  end
end
