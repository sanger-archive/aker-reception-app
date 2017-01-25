require 'rails_helper'

RSpec.describe Printer, type: :model do
  it "is not valid without a name" do
    expect(build(:printer, name: nil)).to_not be_valid
  end
  it "is not valid without a label type" do
  	expect(build(:printer, label_type: nil)).to_not be_valid
  end

  context 'when another printer has the same name'
  	before do
      create(:printer, name: "jeff the printer")
    end
    it "is not valid with duplicate name" do
      expect(build(:printer, name: "jeff the printer")).to_not be_valid
    end
end
