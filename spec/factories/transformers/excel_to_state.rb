# frozen_string_literal: true

FactoryBot.define do
  factory :excel_to_state, class: Transformers::ExcelToState do
    initialize_with do
      new(path: '')
    end
  end
end
