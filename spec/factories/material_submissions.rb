FactoryGirl.define do
  factory :material_submission do
    labware_type {|lt| lt.association(:labware_type, num_of_cols: 1, num_of_rows: 1,
      row_is_alpha: true, col_is_alpha: true)}

    contact
    user

    # A "Claimable" Submission is one that has a status of "printed"
    # and has at least one Labware that is "ready_for_claim"
    # See Labware factory for "ready_for_claim" definition
    factory :claimable_material_submission do
      status "printed"

      transient do
        number_of_labwares 3
      end

      after(:create) do |material_submission, evaluator|
        create_list(:labware_ready_for_claim, evaluator.number_of_labwares, material_submission: material_submission)
      end
    end
  end
end
