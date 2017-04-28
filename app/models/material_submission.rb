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

  belongs_to :user
  belongs_to :labware_type, optional: true
  belongs_to :contact, optional: true
  accepts_nested_attributes_for :contact, update_only: true

  has_many :labwares

  validates :no_of_labwares_required, numericality: { only_integer: true, greater_than_or_equal_to: 1 },
    if: :active_or_labware?

  validates :supply_labwares, inclusion: { in: [true, false] }, if: :active_or_labware?
  validates :labware_type_id, presence: true, if: :active_or_labware?
  validates :address, presence: true, if: :active?
  validates :contact, presence: true, if: :active?
  validate :each_labware_has_biomaterial, if: :active?

  before_save :create_labware, if: -> { labware_type_id_changed? || no_of_labwares_required_changed? }

  #accepts_nested_attributes_for :labwares

  scope :active, -> { where(status: MaterialSubmission.ACTIVE) }
  scope :awaiting, -> { where(status: MaterialSubmission.AWAITING) }
  scope :pending, -> { where.not(status: [MaterialSubmission.ACTIVE, MaterialSubmission.AWAITING, MaterialSubmission.CLAIMED]) }
  scope :for_user, ->(user) { where(user_id: user.id) }

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

  def email
    user&.email
  end

  def update(params)
    update_attributes(params) && labwares.all?(&:valid?)
  end

  private

  # Deletes any labware linked to this submission, and creates
  # new ones based on the requested labware fields
  def create_labware
    if labwares
      labwares.each { |lw| lw.destroy! }
    end
    labwares = []
    (1..no_of_labwares_required).each do |i|
      labwares << Labware.create(material_submission: self, labware_index: i)
    end
  end

  def each_labware_has_biomaterial
    unless labwares.all? { |labware| labware.biomaterials.count > 0 }
      errors.add(:labwares, "must each have at least one Biomaterial")
    end
  end


end
