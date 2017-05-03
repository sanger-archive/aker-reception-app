class Labware < ApplicationRecord
  belongs_to :material_submission
  has_one :material_reception

  alias_attribute :uuid, :container_id

  scope :with_barcode, ->(barcode) { where(barcode: barcode) }

  def labware_type
    material_submission.labware_type
  end

  def increment_print_count!
    update_attributes(print_count: print_count+1)
  end

  def num_of_rows
    labware_type.num_of_rows
  end

  def num_of_cols
    labware_type.num_of_cols
  end

  def col_is_alpha
    labware_type.col_is_alpha
  end

  def row_is_alpha
    labware_type.row_is_alpha
  end

  def size
    num_of_rows * num_of_cols
  end

  def barcode_printed?
    print_count > 0
  end

  def received?
    material_reception.present?
  end

  def positions
    if (!col_is_alpha && !row_is_alpha)
      return (1..size).map(&:to_s)
    end

    if col_is_alpha
      x = ("A"..("A".ord + num_of_cols - 1).chr).to_a
    else
      x = (1..num_of_cols).map(&:to_s)
    end

    if row_is_alpha
      y = ("A"..("A".ord + num_of_rows - 1).chr).to_a
    else
      y = (1..num_of_rows).map(&:to_s)
    end

    y.product(x).map { |a,b| a+':'+b }
  end

end
