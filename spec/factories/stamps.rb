require 'securerandom'

FactoryGirl.define do
  factory :stamp, class: 'StampClient::Stamp' do
    id { SecureRandom.uuid }
    sequence(:name) { |n| "Stamp #{n}" }
    add_attribute("owner-id") { "abc@sanger.ac.uk" }
  end
end
