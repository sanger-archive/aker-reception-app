FactoryBot.define do
  factory :material_submission do
    labware_type {|lt| lt.association(:labware_type, num_of_cols: 1, num_of_rows: 1,
      row_is_alpha: true, col_is_alpha: true)}
    owner_email 'owner@sanger.ac.uk'
    contact
    supply_labwares true
    address "Elmo\n 1 Sesame Street\n New York"
    supply_decappers true

    trait :active do
      status "active"
    end

    trait :printed do
      status "printed"
    end

    trait :dispatched do
      dispatch_date 1.day.ago
    end

    factory :active_material_submission, traits: [:active]
    factory :printed_material_submission, traits: [:printed]
    factory :dispatched_material_submission, traits: [:printed, :dispatched]
  end
end
