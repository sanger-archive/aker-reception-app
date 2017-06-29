FactoryGirl.define do
  factory :user do
    sequence(:email) { |n| "user#{n}@sanger.ac.uk" }
  end
end
