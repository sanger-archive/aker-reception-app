class RemoveColumnDispatchedFromMaterialSubmissions < ActiveRecord::Migration[5.0]
  def change
    remove_column :material_submissions, :dispatched, :boolean
    add_index :material_submissions, :dispatch_date
  end
end
