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

  belongs_to :labware_type, optional: true
  belongs_to :contact, optional: true
  accepts_nested_attributes_for :contact, update_only: true

  has_many :labwares, dependent: :destroy

  validates :no_of_labwares_required, numericality: { only_integer: true, greater_than_or_equal_to: 1 },
    if: :labware_or_later?

  validates :supply_labwares, inclusion: { in: [true, false] }, if: :labware_or_later?
  validates :labware_type_id, presence: true, if: :labware_or_later?
  validates :address, presence: true, if: :last_step?
  validates :contact, presence: true, if: :last_step?
  validate :each_labware_has_contents, if: :last_step?
  validates :material_submission_uuid, presence: true
  validates :owner_email, presence: true

  before_save :create_labware, if: -> { labware_type_id_changed? || no_of_labwares_required_changed? }
  before_save :check_supply_decappers

  after_initialize :create_uuid

  scope :active, -> { where(status: MaterialSubmission.ACTIVE) }
  scope :printed, -> { where(status: MaterialSubmission.PRINTED) }
  # broken submissions are not listed
  scope :pending, -> { where(status: [nil, 'labware', 'provenance', 'ethics', 'dispatch']) }
  scope :for_user, ->(owner) { where(owner_email: owner.email) }

  def create_uuid
    self.material_submission_uuid ||= SecureRandom.uuid
  end

  def active?
    status == MaterialSubmission.ACTIVE
  end

  def last_step?
    return false if @last_step.nil?
    @last_step
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

  def supply_labware_type
    return "Label only" unless supply_labwares
    return labware_type.name + " with decappers" if supply_decappers
    return labware_type.name
  end

  def update(params)
    if !params[:last_step].nil?
      @last_step = params[:last_step]
      params.delete(:last_step)
    end
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

  # return the user who confirmed the hmdmc
  # we currently assume that all the contents of the labware are populated with
  # the same hmdmc data
  def first_confirmed_no_hmdmc
    return nil if labwares.nil?
    labwares.each do |lw|
      h = lw.first_confirmed_no_hmdmc
      return h if h
    end
    nil
  end

  # Get the total number of samples for this submission
  # Do not sum the size of the labware but the actual number (length) of contents
  def total_samples
    labwares.sum { |labware| labware.contents.length }
  end

private

  # Make sure supply_decappers is false unless other fields are appropriate
  def check_supply_decappers
    if supply_decappers && !(supply_labwares && labware_type&.uses_decapper)
      self.supply_decappers = false
    end
  end

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
