class MaterialReception < ApplicationRecord
  belongs_to :labware

  validates :labware, uniqueness: { message: "cannot be received twice" }

  def barcode_value
    labware && labware.barcode && labware.barcode.value
  end

  def barcode_value=(barcode)
    self.labware = Labware.with_barcode(barcode).first
  end

  def presenter
    return {:error => 'Cannot find the barcode'} unless barcode_value
    return {:error => 'Labware already received'} if created_at.nil?
    {
      :labware => { :barcode => barcode_value},
      :created_at => created_at,
      :updated_at => created_at
    }
  end

end
