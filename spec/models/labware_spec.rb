require 'rails_helper'
require 'webmock/rspec'

RSpec.describe Labware, type: :model do

  def make_labware(num_of_rows, num_of_cols, row_is_alpha=false, col_is_alpha=false, attrs=nil)
    labware_type = create(:labware_type, num_of_cols: num_of_cols, num_of_rows: num_of_rows, row_is_alpha: row_is_alpha, col_is_alpha: col_is_alpha)
    material_submission = create(:material_submission, labware_type: labware_type)
    lw_args = {
      material_submission: material_submission,
      labware_index: 1,
    }
    if attrs
      lw_args.merge!(attrs)
    end
    Labware.new(lw_args)
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

      it 'returns an array of numerical strings for its well names' do
        expected = '1 2 3 4 5 6 7 8 9'.split
        expect(@labware.positions).to eq((1..9).map(&:to_s))
      end
    end

    context 'when col_is_alpha' do
      before do
        @labware = make_labware(3,2, false, true)
      end

      it 'returns an array with letters for columns' do
        expected = '1:A 1:B 2:A 2:B 3:A 3:B'.split
        expect(@labware.positions).to eq(expected)
      end
    end

    context 'when row_is_alpha' do
      before do
        @labware = make_labware(3, 2, true, false)
      end

      it 'returns an array with letters for rows' do
        expected = 'A:1 A:2 B:1 B:2 C:1 C:2'.split
        expect(@labware.positions).to eq(expected)
      end
    end
  end

  describe "#barcode_printed?" do
    context 'when print_count is zero' do
      before do
        @labware = make_labware(1,1,false,false, {print_count: 0})
      end
      it "is false" do
        expect(@labware.barcode_printed?).to eq false
      end
    end
    context 'when print_count is 1' do
      before do
        @labware = make_labware(1,1,false,false, {print_count: 1})
      end
      it "is true" do
        expect(@labware.barcode_printed?).to eq true
      end
    end
    context 'when print_count is more than 1' do
      before do
        @labware = make_labware(1,1,false,false, {print_count: 2})
      end
      it "is true" do
        expect(@labware.barcode_printed?).to eq true
      end
    end
  end

  describe "#received?" do
    context "when labware has a reception" do
      before do
        @labware = create(:labware, print_count: 1)
        reception = create(:material_reception, labware_id: @labware.id)
      end

      it "should return true" do
        expect(@labware.received?).to eq true
      end
    end

    context "when labware has no reception" do
      before do
        @labware = create(:labware, print_count: 1)
      end

      it "should return false" do
        expect(@labware.received?).to eq false
      end
    end
  end

  describe "properties taken from labware type" do
    before do
      @lw1 = make_labware(1, 2, false, true)
      @lw2 = make_labware(3, 1, true, false)
    end

    it "should have correct num_of_rows" do
      expect(@lw1.num_of_rows).to eq(1)
      expect(@lw2.num_of_rows).to eq(3)
    end

    it "should have correct num_of_cols" do
      expect(@lw1.num_of_cols).to eq(2)
      expect(@lw2.num_of_cols).to eq(1)
    end

    it "should have correct row_is_alpha" do
      expect(@lw1.row_is_alpha).to eq(false)
      expect(@lw2.row_is_alpha).to eq(true)
    end

    it "should have correct col_is_alpha" do
      expect(@lw1.col_is_alpha).to eq(true)
      expect(@lw2.col_is_alpha).to eq(false)
    end
  end

  describe "#increment_print_count!" do
    before do
      @labware = make_labware(1,2)
    end

    it "should increment the print count" do
      expect(@labware.print_count).to eq 0
      @labware.increment_print_count!
      expect(@labware.print_count).to eq 1
      @labware.increment_print_count!
      expect(@labware.print_count).to eq 2
    end
  end

  describe "#with_barcode" do
    before do
      @lw1 = make_labware(1, 2, false, false, {barcode: 'AKER-1'})
      @lw2 = make_labware(1, 2, false, false, {barcode: 'AKER-2'})
      @lw1.save!
      @lw2.save!
    end

    it "should find the labware with the right barcode" do
      r = Labware.with_barcode('AKER-1')
      expect(r.length).to eq 1
      expect(r.first). to eq @lw1
      r = Labware.with_barcode('AKER-2')
      expect(r.length).to eq 1
      expect(r.first). to eq @lw2
    end

    it "should not find the labware with the wrong barcode" do
      r = Labware.with_barcode('AKER-0')
      expect(r).to be_empty
    end

  end
end
