class AddDispatchedToMaterialSubmission < ActiveRecord::Migration[5.0]
  def change
    add_column :material_submissions, :dispatched?, :boolean, default: false
  end
end
