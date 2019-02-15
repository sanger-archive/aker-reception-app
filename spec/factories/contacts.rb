# frozen_string_literal: true

FactoryBot.define do
  factory :contact do
    fullname { 'Jeff' }
    email { generate(:contact_email) }
  end

  sequence :contact_email do |n|
    "user#{n}@email"
  end
end
