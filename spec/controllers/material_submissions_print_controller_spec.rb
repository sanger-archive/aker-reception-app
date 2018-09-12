require 'rails_helper'

RSpec.describe MaterialSubmissions::PrintController, type: :controller  do
  it_behaves_like 'service that validates credentials', [:index]
end
