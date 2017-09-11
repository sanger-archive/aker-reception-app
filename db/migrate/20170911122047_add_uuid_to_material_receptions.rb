class AddUuidToMaterialReceptions < ActiveRecord::Migration[5.0]
  def up
    add_column :material_receptions, :material_reception_uuid, :string

    # add a UUID for all existing submissions
    MaterialReception.find_each do |reception|
      reception.material_reception_uuid = SecureRandom.uuid
      reception.save!
    end
  end

  def down
    remove_column :material_receptions, :material_reception_uuid, :string
  end
end
