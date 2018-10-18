FactoryBot.define do

  factory :labware_type do
    num_of_cols 12
    num_of_rows 8
    col_is_alpha false
    row_is_alpha false
    name { generate(:labware_type_names) }
    description "A piece of labware"
  end

  sequence :labware_type_names do |n|
    "labware_type_#{n}"
  end

  factory :plate_labware_type, class: LabwareType do
    num_of_cols 12
    num_of_rows 8
    col_is_alpha false
    row_is_alpha false
    name "Plate"
    description "A plate"
  end

  factory :tube_labware_type, class: LabwareType do
    num_of_cols 1
    num_of_rows 1
    col_is_alpha false
    row_is_alpha false
    name "Tube"
    description "A tube"
  end

  factory :rack_labware_type, class: LabwareType do
    num_of_cols 12
    num_of_rows 8
    col_is_alpha false
    row_is_alpha true
    uses_decapper true
    name "Rack"
    description "A rack"
  end
end
