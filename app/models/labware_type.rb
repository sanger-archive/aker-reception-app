class LabwareType < ApplicationRecord

  validates :name, presence: true
  validates :x_dimension_size, presence: true, numericality: { integer: true, greater_than: 0 }
  validates :y_dimension_size, presence: true, numericality: { integer: true, greater_than: 0 }
  validates :x_dimension_is_alpha, inclusion: { in: [true, false] }
  validates :y_dimension_is_alpha, inclusion: { in: [true, false] }

  def self.create_labwares(params)
    find(params.fetch(:labware_type_id)).create_labwares(params.fetch(:number, 1))
  end

  def create_labwares(number = 1)
    labware_args = Array.new(number, { labware_type: self })

    # TODO don't base this on size!
    case size
    when 1
      return Tube.create(labware_args)
    else
      return Plate.create(labware_args)
    end
  end

  def size
    x_dimension_size * y_dimension_size
  end

end
