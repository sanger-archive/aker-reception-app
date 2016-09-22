class Biomaterial < ApplicationRecord
  belongs_to :containable, polymorphic: true, optional: true

  validates_presence_of :supplier_name, :donor_name, :gender, :common_name, :phenotype

  before_create :set_uuid, unless: :uuid?

private

  def set_uuid
    self.uuid = UUID.new.generate
  end
end
