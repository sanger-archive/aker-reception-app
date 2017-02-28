class ChangeLabwareIdInReception < ActiveRecord::Migration[5.0]
  def change
    ActiveRecord::Base.transaction do
      remove_foreign_key :material_receptions, :labwares
      change_column :material_receptions, :labware_id, :string
      #remove_reference :material_receptions, :labware, index: true
    end
  end
end
