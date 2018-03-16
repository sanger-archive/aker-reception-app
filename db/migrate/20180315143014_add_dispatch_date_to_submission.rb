class AddDispatchDateToSubmission < ActiveRecord::Migration[5.0]
  def change
    add_column :material_submissions, :dispatch_date, :datetime
  end
end
