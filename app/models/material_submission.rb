class MaterialSubmission < ApplicationRecord

  def self.ACTIVE
    'active'
  end

  def self.PRINTED
    'printed'
  end

  def self.BROKEN
    'broken'
  end

  belongs_to :user
  belongs_to :labware_type, optional: true
  belongs_to :contact, optional: true
  accepts_nested_attributes_for :contact, update_only: true

  has_many :labwares, dependent: :destroy

  validates :no_of_labwares_required, numericality: { only_integer: true, greater_than_or_equal_to: 1 },
    if: :labware_or_later?

  validates :supply_labwares, inclusion: { in: [true, false] }, if: :labware_or_later?
  validates :labware_type_id, presence: true, if: :labware_or_later?
  validates :address, presence: true, if: :active?
  validates :contact, presence: true, if: :active?
  validate :each_labware_has_contents, if: :active?

  before_save :create_labware, if: -> { labware_type_id_changed? || no_of_labwares_required_changed? }

  scope :active, -> { where(status: MaterialSubmission.ACTIVE) }
  scope :printed, -> { where(status: MaterialSubmission.PRINTED) }
  # broken submissions are not listed
  scope :pending, -> { where(status: [nil, 'labware', 'provenance', 'ethics', 'dispatch']) }
  scope :for_user, ->(user) { where(user_id: user.id) }

  def active?
    status == MaterialSubmission.ACTIVE
  end

  def active_or_labware?
    return false if status.nil?
    active? || status.include?('labware')
  end

  def labware_or_later?
    return ['labware', 'provenance', 'ethics', 'dispatch'].include?(status)
  end

  def active_or_provenance?
    return false if status.nil?
    active? || status.include?('provenance')
  end

  def active_or_dispatch?
    return false if status.nil?
    active? || status.include?('dispatch')
  end

  def active_or_printed?
    return false if status.nil?
    active? || status==MaterialSubmission.PRINTED
  end

  def pending?
    status.nil? || ['labware', 'provenance', 'ethics', 'dispatch'].include?(status)
  end

  def broken?
    return status==MaterialSubmission.BROKEN
  end

  def broken!
    update_attributes(status: MaterialSubmission.BROKEN)
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

  def supply_labware_type
    supply_labwares ? labware_type.name : "Label only"
  end

  def update(params)
    update_attributes(params) && labwares.all?(&:valid?)
  end

  def any_human_material?
    labwares && labwares.any? { |lw| lw.any_human_material? }
  end

  def ethical?
    labwares && labwares.all? { |lw| lw.ethical? }
  end

  def set_hmdmc(hmdmc, username)
    return if labwares.nil?
    labwares.each { |lw| lw.set_hmdmc(hmdmc, username) }
  end

  def set_hmdmc_not_required(username)
    return if labwares.nil?
    labwares.each { |lw| lw.set_hmdmc_not_required(username) }
  end

  def clear_hmdmc
    return if labwares.nil?
    labwares.each { |lw| lw.clear_hmdmc }
  end

  def first_hmdmc
    return nil if labwares.nil?
    labwares.each do |lw|
      h = lw.first_hmdmc
      return h if h
    end
    nil
  end

  def confirmed_no_hmdmc?
    labwares && labwares.any? { |lw| lw.confirmed_no_hmdmc? }
  end

  private

  # Deletes any labware linked to this submission, and creates
  # new ones based on the requested labware fields
  def create_labware
    labwares.clear unless labwares.empty?

    (1..no_of_labwares_required).each do |i|
      self.labwares.create(labware_index: i)
    end
  end

  def each_labware_has_contents
    unless labwares.all? { |labware| labware.contents.present? }
      errors.add(:labwares, "must each have at least one Biomaterial")
    end
  end


end
