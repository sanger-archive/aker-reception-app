class Biomaterial < ApplicationRecord
  belongs_to :containable, polymorphic: true, optional: true

  validates_presence_of :supplier_name, :donor_name, :gender, :common_name, :phenotype
end
