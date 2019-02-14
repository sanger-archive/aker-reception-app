FactoryBot.define do
  factory :user, class: OpenStruct do
    email { 'user@sanger.ac.uk' }
    groups { %w[world team252] }

    initialize_with { new(attributes) }
  end
end
