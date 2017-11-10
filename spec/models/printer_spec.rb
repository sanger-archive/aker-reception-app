require 'rails_helper'

RSpec.describe Printer, type: :model do

  describe '#name' do
    it 'should be sanitised' do
      expect(create(:printer, name: '    d304bc   ').name).to eq('d304bc')
    end
  end


  describe 'validation' do
    it "is not valid without a name" do
      expect(build(:printer, name: nil)).to_not be_valid
    end
    it "is not valid without a label type" do
    	expect(build(:printer, label_type: nil)).to_not be_valid
    end

    context 'when another printer has the same name' do
    	before do
        create(:printer, name: "jeff the printer")
      end
      it "is not valid with duplicate name" do
        expect(build(:printer, name: "jeff the printer")).to_not be_valid
      end
    end

    it 'is not valid without a unique sanitised name' do
      create(:printer, name: 'd304bc')
      expect(build(:printer, name: '   D304BC  ')).not_to be_valid
    end
    it 'is valid with a unique sanitised name' do
      expect(build(:printer, name: '   D304BC  ')).to be_valid
    end
  end
end
