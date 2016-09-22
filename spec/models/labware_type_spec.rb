require 'rails_helper'

RSpec.describe LabwareType, type: :model do

  it "is not valid without x_dimension_size" do
    expect(build(:labware_type, x_dimension_size: nil)).to_not be_valid
  end

  it "is not valid with an x_dimension_size that is not an integer" do
    expect(build(:labware_type, x_dimension_size: 'abc')).to_not be_valid
  end

  it "is not valid with an x_dimension_size that is not greater than 0" do
    expect(build(:labware_type, x_dimension_size: 0)).to_not be_valid
    expect(build(:labware_type, x_dimension_size: -1)).to_not be_valid
  end

  it "is not valid without y_dimension_size" do
    expect(build(:labware_type, y_dimension_size: nil)).to_not be_valid
  end

  it "is not valid with a y_dimension_size that is not an integer" do
    expect(build(:labware_type, y_dimension_size: 'abc')).to_not be_valid
  end

  it "is not valid with an y_dimension_size that is not greater than 0" do
    expect(build(:labware_type, y_dimension_size: 0)).to_not be_valid
    expect(build(:labware_type, y_dimension_size: -1)).to_not be_valid
  end

  it "is not valid without x_dimension_is_alpha" do
    expect(build(:labware_type, x_dimension_is_alpha: nil)).to_not be_valid
  end

  it "is not valid without y_dimension_is_alpha" do
    expect(build(:labware_type, y_dimension_is_alpha: nil)).to_not be_valid
  end

  it "is not valid without a name" do
    expect(build(:labware_type, name: nil)).to_not be_valid
  end

end
