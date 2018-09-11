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

  validates :no_of_labwares_required,
            numericality: { only_integer: true, greater_than_or_equal_to: 1, less_than_or_equal_to: 10 },
            if: :labware_or_later?

  validates :supply_labwares, inclusion: { in: [true, false] }, if: :labware_or_later?
  validates :labware_type_id, presence: true, if: :labware_or_later?
  validates :address, presence: true, if: :last_step?
  validates :contact, presence: true, if: :last_step?
  validate :each_labware_has_contents, if: :last_step?
  validates :material_submission_uuid, presence: true
  validates :owner_email, presence: true
  validates :status, inclusion: { in: %w(printed) }, if: :dispatch_date_changed?

  before_validation :sanitise_owner
  before_save :sanitise_owner

  before_save :create_labware, if: -> { labware_type_id_changed? || no_of_labwares_required_changed? }
  before_save :check_supply_decappers

  after_initialize :create_uuid

  scope :dispatched, -> { where.not(dispatch_date: nil) }
  scope :not_dispatched, -> { where(dispatch_date: nil) }
  scope :awaiting_receipt, -> { dispatched.left_outer_joins(labwares: :material_reception).where(material_receptions: { labware_id: nil }).distinct }

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
    active? || status == MaterialSubmission.PRINTED
  end

  def after_provenance?
    return false if labwares.blank?
    return false unless status
    return false if ['labware', 'provenance'].include?(status)
    return labwares.all? { |labware| labware.contents.present? }
  end

  def pending?
    status.nil? || ['labware', 'provenance', 'ethics', 'dispatch'].include?(status)
  end

  def broken?
    return status == MaterialSubmission.BROKEN
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

  def update(params)
    unless params[:last_step].nil?
      @last_step = params[:last_step]
      params.delete(:last_step)
    end
    update_attributes(params) && labwares.all?(&:valid?)
  end

  def any_human_material?
    labwares && labwares.any? { |lw| lw.any_human_material? }
  end

  def any_human_material_no_hmdmc?
    labwares && labwares.any? { |lw| lw.any_human_material_no_hmdmc? }
  end

  def ethical?
    labwares && labwares.all? { |lw| lw.ethical? }
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

  # Return the user who confirmed the HMDMC
  # We currently assume that all the contents of the labware are populated with the same hmdmc data
  # TODO: this assumption is now incorrect, as each material can have it's own (potentially unique)
  # HMDMC number
  def first_confirmed_no_hmdmc
    return nil if labwares.nil?
    labwares.each do |lw|
      h = lw.first_confirmed_no_hmdmc
      return h if h
    end
    nil
  end

  # Returns a set of all unique HMDMC numbers in the submission
  def hmdmc_set
    hmdmcs = Set.new()
    return hmdmcs if labwares.nil?
    labwares.each do |lw|
      hmdmcs.merge(lw.hmdmc_set)
    end
    hmdmcs
  end

  # Get the total number of samples for this submission
  # Do not sum the size of the labware but the actual number (length) of contents
  def total_samples
    labwares.sum { |labware| labware.contents.length }
  end

  def sanitise_owner
    if owner_email
      sanitised = owner_email.strip.downcase
      if sanitised != owner_email
        self.owner_email = sanitised
      end
    end
  end

  def dispatched?
    dispatch_date?
  end

  def dispatch!
    update_attributes!(dispatch_date: DateTime.now)
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
      labwares.create(labware_index: i)
    end
  end

  def each_labware_has_contents
    errors.add(:labwares, 'must each have at least one Biomaterial') unless labwares.all? { |labware| labware.contents.present? }
  end
end
