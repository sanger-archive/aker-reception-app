class MaterialReception < ApplicationRecord

  validates :labware_id, uniqueness: { message: "cannot be received twice" }
  validate :validate_barcode_printed, on: :create

  def barcode_value
    labware&.barcode
  end

  def labware
    labware_id && Labware.find(labware_id)
  end

  def barcode_value=(barcode)
    self.labware_id = Labware.with_barcode(barcode).first.id
  end

  def validate_barcode_printed
    unless labware
      errors.add(:labware, "could not be found")
    else
      errors.add(:labware, "needs to have been printed") unless labware.barcode_printed?
    end
  end

  def labware_already_received?
    MaterialReception.where(:labware_id => labware.id).count > 0
  end


  def presenter
    if invalid?
      return {:error => 'Cannot find the barcode'} unless barcode_value
      return {:error => 'Labware already received'} if labware_already_received?
      return {:error => 'This barcode has not been printed yet. Please contact the administrator'} unless labware.barcode_printed?
    else
      {
        :labware => { :barcode => barcode_value},
        :created_at => created_at,
        :updated_at => created_at
      }
    end
  end

  def all_received?
    labware.material_submission.labwares.all?(&:received?)
  end

end
