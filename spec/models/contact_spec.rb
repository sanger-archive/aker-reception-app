require 'rails_helper'

RSpec.describe Contact, type: :model do

  it "should have fullname_and_email" do
    c = build(:contact, fullname: "Jeff", email: "jeff@jeff")
    expect(c.fullname_and_email).to eq ("Jeff <jeff@jeff>")
  end

end
