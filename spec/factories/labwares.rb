FactoryGirl.define do
  factory :labware do
    sequence(:labware_index) { |n| n }
    material_submission
    print_count 0
    barcode nil
    container_id nil

    trait :printed do
      print_count 1
    end

    trait :has_contents do
      contents { { "1": { 'id': 1, 'scientific_name': 'Homo Sapiens' } } }
    end

    factory :printed_labware, traits: [:printed]
    factory :printed_with_contents_labware, traits: [:printed, :has_contents]
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
