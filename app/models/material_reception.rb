class MaterialReception < ApplicationRecord
  belongs_to :labware

  before_create :receive_labware

  validates :labware, uniqueness: { message: "cannot be received twice" }
  validate :validate_barcode_printed, on: :create

  def receive_labware
    return false unless labware.barcode_printed?
    labware.received_unclaimed
  end

  def barcode_value
    labware && labware.barcode && labware.barcode.value
  end

  def barcode_value=(barcode)
    self.labware = Labware.with_barcode(barcode).first
  end

  def validate_barcode_printed
    unless labware && labware.barcode_printed?
      errors.add(:labware, "needs a printed barcode")
    end
  end

  def labware_already_received?
    MaterialReception.where(:labware => labware).count > 0
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

  def complete_set?
    labware.material_submission.labwares.all?(&:received_unclaimed?)
  end

  def complete_set?
    labware.material_submission.labwares.all?(&:received_unclaimed?)
  end

end
