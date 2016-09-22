class CreateBiomaterials < ActiveRecord::Migration[5.0]
  def change
    create_table :biomaterials do |t|
      t.string :uuid
      t.string :supplier_name
      t.string :donor_name
      t.string :gender
      t.string :common_name
      t.string :phenotype
      t.references :containable, polymorphic: true

      t.timestamps
    end
  end
end
