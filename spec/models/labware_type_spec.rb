require 'rails_helper'

RSpec.describe LabwareType, type: :model do

  describe 'validation' do
    it "is not valid without num_of_cols" do
      expect(build(:labware_type, num_of_cols: nil)).to_not be_valid
    end

    it "is not valid with a num_of_cols that is not an integer" do
      expect(build(:labware_type, num_of_cols: 'abc')).to_not be_valid
    end

    it "is not valid with a num_of_cols that is not greater than 0" do
      expect(build(:labware_type, num_of_cols: 0)).to_not be_valid
      expect(build(:labware_type, num_of_cols: -1)).to_not be_valid
    end

    it "is not valid without num_of_rows" do
      expect(build(:labware_type, num_of_rows: nil)).to_not be_valid
    end

    it "is not valid with a num_of_rows that is not an integer" do
      expect(build(:labware_type, num_of_rows: 'abc')).to_not be_valid
    end

    it "is not valid with a num_of_rows that is not greater than 0" do
      expect(build(:labware_type, num_of_rows: 0)).to_not be_valid
      expect(build(:labware_type, num_of_rows: -1)).to_not be_valid
    end

    it "is not valid without col_is_alpha" do
      expect(build(:labware_type, col_is_alpha: nil)).to_not be_valid
    end

    it "is not valid without row_is_alpha" do
      expect(build(:labware_type, row_is_alpha: nil)).to_not be_valid
    end

    it "is not valid without a name" do
      expect(build(:labware_type, name: nil)).to_not be_valid
    end
  end

  describe '#size' do
    it "should be correct" do
      expect(build(:labware_type, num_of_rows: 2, num_of_cols: 3).size).to eq 6
    end
  end

  describe '#name' do
    it 'should be sanitised' do
      expect(create(:labware_type, name: '   Alpha   Beta   ').name).to eq('Alpha Beta')
    end
  end

end
