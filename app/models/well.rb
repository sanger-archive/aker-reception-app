class Well < ApplicationRecord
  belongs_to :plate
  has_one :biomaterial, as: :containable

  validates :position, presence: true, uniqueness: { scope: :labware_id }

  accepts_nested_attributes_for :biomaterial, reject_if: :all_attributes_blank?

  def all_attributes_blank?(attributes)
    [:supplier_name, :donor_name, :gender, :common_name, :phenotype].all? { |attribute| attributes[attribute].blank? }
  end
end
