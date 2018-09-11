FactoryBot.define do
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

    trait :has_barcode do
      sequence(:labware_index)
      barcode { generate(:labware_barcode) }
    end

    trait :dispatched do
      association :material_submission, factory: :dispatched_material_submission
    end

    trait :received do
      material_reception
    end

    factory :barcoded_labware, traits: [:has_barcode]
    factory :printed_labware, traits: [:has_barcode, :printed]
    factory :printed_with_contents_labware, traits: [:has_barcode, :printed, :has_contents]
    factory :dispatched_labware, traits: [:has_barcode, :has_contents, :printed, :dispatched]
    factory :received_labware, traits: [:has_barcode, :has_contents, :printed, :dispatched, :received]
  end

  sequence :labware_barcode do |n|
    "AKER-#{n}"
  end
end
