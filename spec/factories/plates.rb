FactoryGirl.define do
  factory :plate do
    association :labware_type, factory: :plate_labware_type
  end
end
