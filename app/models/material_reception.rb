class MaterialReception < ApplicationRecord

  belongs_to :labware
  validates :labware_id, uniqueness: { message: "already received" }
  validates :material_reception_uuid, presence: true
  validate :barcode_printed?, on: :create

  after_initialize :create_uuid

  def create_uuid
    self.material_reception_uuid ||= SecureRandom.uuid
  end

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

end
