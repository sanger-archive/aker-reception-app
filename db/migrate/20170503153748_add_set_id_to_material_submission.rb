class AddSetIdToMaterialSubmission < ActiveRecord::Migration[5.0]
  def change
  	add_column :material_submissions, :set_id, :uuid
  end
end
