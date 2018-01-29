FactoryBot.define do
  factory :contact_group do
    sequence(:name) { |n| "group#{n}" }
  end
end
