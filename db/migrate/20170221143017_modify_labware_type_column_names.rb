class ModifyLabwareTypeColumnNames < ActiveRecord::Migration[5.0]
  def change

    ActiveRecord::Base.transaction do
      rename_column :labware_types, :x_dimension_size, :num_of_cols
      rename_column :labware_types, :y_dimension_size, :num_of_rows
      rename_column :labware_types, :x_dimension_is_alpha, :col_is_alpha
      rename_column :labware_types, :y_dimension_is_alpha, :row_is_alpha
    end
  end
end
