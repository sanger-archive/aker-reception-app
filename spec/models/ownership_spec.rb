require 'rails_helper'

RSpec.describe Ownership, type: :model do

  it "creating an ownership creates it in the ownership service" do
  	owner = Ownership.new({})

  	owner.save
  end
end
