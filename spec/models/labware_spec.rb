require 'rails_helper'
require 'webmock/rspec'
RSpec.describe Labware, type: :model do

  describe '#size' do
    it "returns its size" do
      labware_type = create(:labware_type, num_of_cols: 12, num_of_rows: 8)
      expect(labware_type.create_labware.size).to eq(96)
    end
  end

  describe '#positions' do

    context 'when both dimensions are not alpha' do

      before do
        labware_type = create(:labware_type, num_of_cols: 3, num_of_rows: 3)
        @labware = labware_type.create_labware
      end

      it 'returns an array of integers for each of its well names' do
        expect(@labware.positions).to eq((1..9).to_a)
      end

    end

    context 'when x_dimension_is_alpha is true' do

      before do
        labware_type = create(:labware_type, num_of_cols: 3, num_of_rows: 3, col_is_alpha: true)
        @labware = labware_type.create_labware
      end

      it 'returns an array with letters for the x dimension' do
        expected = ['1A', '1B', '1C', '2A', '2B', '2C', '3A', '3B', '3C']
        expect(@labware.positions).to eq(expected)
      end

    end

    context 'when y_dimension_is_alpha is true' do

      before do
        labware_type = create(:labware_type, num_of_cols: 3, num_of_rows: 3, row_is_alpha: true)
        @labware = labware_type.create_labware
      end

      it 'returns an array with letters for the y dimension' do
        expected = ['A1', 'A2', 'A3', 'B1', 'B2', 'B3', 'C1', 'C2', 'C3']
        expect(@labware.positions).to eq(expected)
      end

    end

  end


end
