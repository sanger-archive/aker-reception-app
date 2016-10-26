class Labware < ApplicationRecord
  include Barcodeable

  belongs_to :labware_type
  has_one :material_reception

  has_one :material_submission_labware
  has_one :material_submission, through: :material_submission_labware
  has_many :wells, dependent: :destroy

  delegate :size, :x_dimension_is_alpha, :y_dimension_is_alpha, :x_dimension_size, :y_dimension_size, to: :labware_type

  scope :with_barcode, ->(barcode) {
    joins(:barcode).where(:barcodes => {:value => barcode })
  }

  def waiting_receipt
    material_submission_labware.update_attributes(:state => 'awaiting receipt')
  end

  def received_unclaimed
    material_submission_labware.update_attributes(:state => 'received unclaimed')
  end

  def invalid_data
    if invalid?
      wells.map{|w| w if w.invalid?}.compact.map do |invalid_well|
        {
          :labware_id => self.id,
          :well_id => invalid_well.id,
          :errors => invalid_well.errors.messages
        }
      end.flatten.compact
    end
  end


end
