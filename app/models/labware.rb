class Labware < ApplicationRecord
  include Barcodeable

  belongs_to :labware_type
  has_one :material_reception

  has_one :material_submission_labware
  has_one :material_submission, through: :material_submission_labware
  has_many :wells, dependent: :destroy

  accepts_nested_attributes_for :wells

  before_create :build_default_wells
  
  delegate :size, :x_dimension_is_alpha, :y_dimension_is_alpha, :x_dimension_size, :y_dimension_size, to: :labware_type

  scope :with_barcode, ->(barcode) {
    joins(:barcode).where(:barcodes => {:value => barcode })
  }

  def biomaterials
    wells.map(&:biomaterial)
  end

  def waiting_receipt
    material_submission_labware.update_attributes(:state => 'awaiting receipt')
  end

  def received_unclaimed
    material_submission_labware.update_attributes(:state => 'received unclaimed') if barcode_printed?
  end

  def barcode_printed?
    barcode.print_count > 0
  end

  def received_unclaimed?
    material_submission_labware.state == 'received unclaimed'
  end

  def received_unclaimed?
    material_submission_labware.state == 'received unclaimed'
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

  def positions
    if (!x_dimension_is_alpha && !y_dimension_is_alpha)
      return (1..size).to_a
    end

    if x_dimension_is_alpha
      x = ("A"..("A".ord + x_dimension_size - 1).chr).to_a
    else
      x = (1..x_dimension_size).to_a
    end

    if y_dimension_is_alpha
      y = ("A"..("A".ord + y_dimension_size - 1).chr).to_a
    else
      y = (1..y_dimension_size).to_a
    end

    y.product(x).map(&:join)
  end

private

  def build_default_wells
    wells.build(positions.map { |position| { position: position } })
    true
  end


end
