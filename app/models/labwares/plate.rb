class Plate < Labware
  belongs_to :labware_type

  accepts_nested_attributes_for :wells

  before_create :build_default_wells

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
