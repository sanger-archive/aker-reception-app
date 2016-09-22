require 'rails_helper'

RSpec.describe Well, type: :model do

  it "is not valid without a plate" do
    expect(build(:well, plate: nil)).to_not be_valid
  end

  it "is not valid without a position" do
    expect(build(:well, position: nil)).to_not be_valid
  end

  it "is not valid if well already exists on same plate" do
    plate = create(:plate)

    well_a = create(:well, plate: plate, position: "A:1")
    well_b = build(:well, plate: plate, position: "A:1")

    expect(well_b).to_not be_valid
  end
end
