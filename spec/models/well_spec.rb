require 'rails_helper'

RSpec.describe Well, type: :model do

  it "is not valid without a plate" do
    expect(Well.new(labware: nil)).to_not be_valid
  end

  it "is not valid without a position" do
    expect(Well.new(position: nil)).to_not be_valid
  end

  it "is not valid if well already exists on same labware" do
    labware = Labware.new
    well_a = Well.new(labware: labware, position: "A:1")
    well_b = Well.new(labware: labware, position: "A:1")

    labware.wells = [well_a, well_b]

    expect(well_b).to_not be_valid
  end
end
