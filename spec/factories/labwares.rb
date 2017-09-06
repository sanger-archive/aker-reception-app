FactoryGirl.define do
  factory :labware do
    sequence(:labware_index) { |n| n }
    material_submission
    claimed false

    # Labware is "ready_for_claim" if it has a Material Reception (i.e. it has been received)
    # and it has not been claimed already (i.e. claimed is false)
    factory :labware_ready_for_claim do
      print_count 1

      after(:create) do |labware|
        create(:material_reception, labware: labware)
      end
    end
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
