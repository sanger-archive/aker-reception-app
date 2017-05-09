FactoryGirl.define do
  factory :labware do
    labware_index 1
    material_submission
  end

  factory :labware_with_barcode_and_material_submission, class: :labware do
    material_submission {|l| l.association(:material_submission)}
    sequence(:labware_index)
    barcode { generate(:labware_barcode) }  
  end

  sequence :labware_barcode do |n|
    "AKER-#{n}"
  end
end
