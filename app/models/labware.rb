class Labware < ApplicationRecord
  include Barcodeable

  has_one :material_submission_labware, as: :labware
  has_one :material_submission, through: :material_submission_labware

  belongs_to :labware_type

  delegate :size, :x_dimension_is_alpha, :y_dimension_is_alpha, :x_dimension_size, :y_dimension_size, to: :labware_type
end
