class MaterialReception < ApplicationRecord

  belongs_to :labware
  validates :labware_id, uniqueness: { message: "already received" }
  validate :barcode_printed?, on: :create
  validate :barcode_dispatched?, on: :create

  def barcode_value
    labware&.barcode
  end

  def presenter
    if errors.any? or invalid?
      { :error => errors.full_messages.to_sentence }
    else
      {
        :labware => { :barcode => barcode_value},
        :created_at => created_at,
        :updated_at => created_at
      }
    end
  end

  # Returns true if there are receptions for every labware in the submission
  def all_received?
    labware.material_submission.labwares.all?(&:received?)
  end

private

  def barcode_printed?
    return unless labware

    if not labware.barcode_printed?
      errors.add(:labware, "barcode has not been printed. Please contact the administrator.")
    end
  end

  def barcode_dispatched?
    return unless labware

    if not labware.barcode_dispatched?
      errors.add(:labware, "barcode has not been dispatched prior reception. Please contact the administrator.")
    end    
  end

end
