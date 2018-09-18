require 'rails_helper'

RSpec.describe Manifests::DispatchController, type: :controller  do
  it_behaves_like 'service that validates credentials', [:index]
end
