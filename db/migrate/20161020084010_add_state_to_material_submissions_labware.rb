class AddStateToMaterialSubmissionsLabware < ActiveRecord::Migration[5.0]
  def change
    add_column :material_submission_labwares, :state, :text
  end
end
