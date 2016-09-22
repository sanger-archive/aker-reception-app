FactoryGirl.define do
  factory :tube do
    association :labware_type, factory: :tube_labware_type
  end
end
