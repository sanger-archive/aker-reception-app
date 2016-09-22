FactoryGirl.define do

  factory :labware_type do
    x_dimension_size 12
    y_dimension_size 8
    x_dimension_is_alpha false
    y_dimension_is_alpha false
    name "Labware"
    description "A piece of labware"
  end

  factory :plate_labware_type, class: LabwareType do
    x_dimension_size 12
    y_dimension_size 8
    x_dimension_is_alpha false
    y_dimension_is_alpha false
    name "Plate"
    description "A plate"
  end

  factory :tube_labware_type, class: LabwareType do
    x_dimension_size 1
    y_dimension_size 1
    x_dimension_is_alpha false
    y_dimension_is_alpha false
    name "Tube"
    description "A tube"
  end
end
