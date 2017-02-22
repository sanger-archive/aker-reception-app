class MaterialSubmission < ApplicationRecord

  def self.ACTIVE
    'active'
  end

  def self.AWAITING
    'awaiting receipt'
  end

  def self.CLAIMED
    'claimed'
  end

  attr_writer :labwares

  belongs_to :labware_type, optional: true
  belongs_to :contact, optional: true
  accepts_nested_attributes_for :contact, update_only: true

  has_many :material_submission_labwares, dependent: :destroy
  has_many :labware_references, through: :material_submission_labwares

  validates :no_of_labwares_required, numericality: { only_integer: true, greater_than_or_equal_to: 1 },
    if: :active_or_labware?

  validates :supply_labwares, inclusion: { in: [true, false] }, if: :active_or_labware?
  validates :labware_type_id, presence: true, if: :active_or_labware?
  validates :email, presence: true, if: :active?
  validates :address, presence: true, if: :active?
  validates :contact, presence: true, if: :active?
  validate :each_labware_has_biomaterial, if: :active?

  before_save :set_labware, if: -> { labware_type_id_changed? || no_of_labwares_required_changed? }

  #accepts_nested_attributes_for :labwares


  scope :active, -> { where(status: MaterialSubmission.ACTIVE) }
  scope :awaiting, -> { where(status: MaterialSubmission.AWAITING) }
  scope :pending, -> { where.not(status: [MaterialSubmission.ACTIVE, MaterialSubmission.AWAITING, MaterialSubmission.CLAIMED]) }

  def active?
    status == MaterialSubmission.ACTIVE
  end

  def active_or_labware?
    return false if status.nil?
    active? || status.include?('labware')
  end

  def active_or_provenance?
    return false if status.nil?
    active? || status.include?('provenance')
  end

  def active_or_dispatch?
    return false if status.nil?
    active? || status.include?('dispatch')
  end

  def active_or_awaiting?
    return false if status.nil?
    active? || status==MaterialSubmission.AWAITING
  end

  def no_of_labwares_required
    super || 0
  end

  def invalid_labwares
    labwares.select(&:invalid?)
  end

  def labwares
    @labwares ||= material_submission_labwares.map(&:labware)
  end

  def labwares_attributes=(params)
    params.values.each do |labware_attrs|
      Labware.find(labware_attrs["uuid"]).update(labware_attrs)
    end
  end

  def labware
  end

  def material_submission_labwares_attributes=(params)
    debugger
  end

  private

  def set_labware
    material_submission_labwares << LabwareType.create_labwares(number: no_of_labwares_required, labware_type_id: labware_type_id)
  end

  def each_labware_has_biomaterial
    unless labwares.all? { |labware| labware.biomaterials.count > 0 }
      errors.add(:labwares, "must each have at least one Biomaterial")
    end
  end


end
