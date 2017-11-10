FactoryBot.define do

  factory :labware_type do
    num_of_cols 12
    num_of_rows 8
    col_is_alpha false
    row_is_alpha false
    name "Labware"
    description "A piece of labware"
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
    row_is_alpha false
    uses_decapper true
    name "Rack"
    description "A rack"
  end
end
