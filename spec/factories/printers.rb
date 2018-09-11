FactoryBot.define do
  factory :printer do
    sequence(:name) { |n| "Printer #{n}" }
    label_type "MyString"
  end
end
