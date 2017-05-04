require 'rails_helper'
require 'webmock/rspec'

RSpec.describe Labware, type: :model do

  def make_labware(num_of_rows=1, num_of_cols=1, row_is_alpha=false, col_is_alpha=false)
    labware_type = create(:labware_type, num_of_cols: num_of_cols, num_of_rows: num_of_rows, row_is_alpha: row_is_alpha, col_is_alpha: col_is_alpha)
    material_submission = create(:material_submission, labware_type: labware_type)
    Labware.new(material_submission: material_submission, labware_index: 1)
  end

  describe '#size' do
    it "returns its size" do
      labware = make_labware(6, 4)
      expect(labware.size).to eq(24)
    end
  end

  describe '#positions' do

    context 'when both dimensions are not alpha' do

      before do
        @labware = make_labware(3, 3, false, false)
      end

      it 'returns an array of integers for each of its well names' do
        expect(@labware.positions).to eq((1..9).map(&:to_s))
      end

    end

    context 'when col_is_alpha' do

      before do
        @labware = make_labware(3,2, false, true)
      end

      it 'returns an array with letters for the x dimension' do
        expected = ['1:A', '1:B', '2:A', '2:B', '3:A', '3:B']
        expect(@labware.positions).to eq(expected)
      end

    end

    context 'when y_dimension_is_alpha is true' do

      before do
        @labware = make_labware(3, 2, true, false)
      end

      it 'returns an array with letters for the y dimension' do
        expected = ['A:1', 'A:2', 'B:1', 'B:2', 'C:1', 'C:2']
        expect(@labware.positions).to eq(expected)
      end

    end

  end


end
