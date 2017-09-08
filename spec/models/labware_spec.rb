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

  def make_contents(human, options={})
    c = { 'scientific_name' => (human ? 'Homo Sapiens' : 'Mouse') }
    if options.has_key? :hmdmc
      c['hmdmc'] = options[:hmdmc]
    end
    if options.has_key? :hmdmc_user
      c['hmdmc_set_by'] = options[:hmdmc_user]
    end
    if options.has_key? :not_required
      c['hmdmc_not_required_confirmed_by'] = options[:not_required]
    end
    return c
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
        create(:material_reception, labware_id: @labware.id)
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

  describe "#any_human_material?" do
    context "when the labware has no contents" do
      before do
        @lw = make_labware(1,2)
      end
      it "should not be any human material" do
        expect(@lw).not_to be_any_human_material
      end
    end
    context "when the labware contents are not human" do
      before do
        @lw = make_labware(1,2, false,false, { contents: { "1" => make_contents(false) }})
      end
      it "should not be any human material" do
        expect(@lw).not_to be_any_human_material
      end
    end
    context "when the labware has some human material" do
      before do
        @lw = make_labware(1, 2, false, false, { contents: {"1" => make_contents(false), "2" => make_contents(true) }})
      end
      it "should be any human material" do
        expect(@lw).to be_any_human_material
      end
    end
  end

  describe "#ethical?" do
    context "when the labware has no contents" do
      before do
        @lw = make_labware(1,2)
      end
      it "should be ethical" do
        expect(@lw).to be_ethical
      end
    end
    context "when the labware has no human material" do
      before do
        @lw = make_labware(1,2, false,false, { contents: { "1" => make_contents(false) }})
      end
      it "should be ethical" do
        expect(@lw).to be_ethical
      end
    end
    context "when the labware has human material with no HMDMC info" do
      before do
        @lw = make_labware(1, 2, false, false, { contents: {"1" => make_contents(true) }})
      end
      it "should not be ethical" do
        expect(@lw).not_to be_ethical
      end
    end
    context "when the material has an HMDMC number but no HMDMC user" do
      before do
        @lw = make_labware(1,2, false,false, { contents: { "1" => make_contents(true, hmdmc: '12/345') }})
      end
      it "should not be ethical" do
        expect(@lw).not_to be_ethical
      end
    end
    context "when the material has an HMDMC user but no HMDMC number" do
      before do
        @lw = make_labware(1,2, false,false, { contents: { "1" => make_contents(true, hmdmc_user: 'dirk') }})
      end
      it "should not be ethical" do
        expect(@lw).not_to be_ethical
      end
    end
    context "when the material has an HMDMC number and user" do
      before do
        @lw = make_labware(1,2, false,false, { contents: { "1" => make_contents(true, hmdmc: '12/345', hmdmc_user: 'dirk') }})
      end
      it "should be ethical" do
        expect(@lw).to be_ethical
      end
    end
    context "when the material is confirmed not to need an HMDMC" do
      before do
        @lw = make_labware(1,2, false,false, { contents: { "1" => make_contents(true, not_required: 'dirk') }})
      end
      it "should be ethical" do
        expect(@lw).to be_ethical
      end
    end
    context "when there is conflicting HMDMC information" do
      before do
        @lw = make_labware(1,2, false,false, { contents: { "1" => make_contents(true, not_required: 'dirk', hmdmc: '12/345', hmdmc_user: 'dirk') }})
      end
      it "should not be ethical" do
        expect(@lw).not_to be_ethical
      end
    end
    context "when some material has HMDMC and some is not human" do
      before do
        @lw = make_labware(1,2, false,false, { contents: { "1" => make_contents(true, hmdmc: '12/345', hmdmc_user: 'dirk'), "2" => make_contents(false) }})
      end
      it "should be ethical" do
        expect(@lw).to be_ethical
      end
    end
    context "when some material has HMDMC and some is missing HMDMC" do
      before do
        @lw = make_labware(1,2, false,false, { contents: { "1" => make_contents(true, hmdmc: '12/345', hmdmc_user: 'dirk'), "2" => make_contents(true) }})
      end
      it "should not be ethical" do
        expect(@lw).not_to be_ethical
      end
    end
  end

  describe "#set_hmdmc" do
    before do
      @lw = make_labware(1, 2, false, false, { contents: { "1" => make_contents(true, not_required: 'jeff'), "2" => make_contents(false, hmdmc: "99/999")}})

      @lw.set_hmdmc('12/345', 'dirk')
    end
    it "should correct set the fields on the human material" do
      expect(@lw.contents['1']).to eq({
          'scientific_name' => 'Homo Sapiens',
          'hmdmc' => '12/345',
          'hmdmc_set_by' => 'dirk',
        })
    end
    it "should correct set the fields on the nonhuman material" do
      expect(@lw.contents['2']).to eq({
          'scientific_name' => 'Mouse',
        })
    end
  end

  describe "#set_hmdmc_not_required" do
    before do
      @lw = make_labware(1, 2, false, false, { contents: { "1" => make_contents(true, hmdmc_user: 'jeff'), "2" => make_contents(false, hmdmc: "99/999")}})

      @lw.set_hmdmc_not_required('dirk')
    end
    it "should correct set the fields on the human material" do
      expect(@lw.contents['1']).to eq({
          'scientific_name' => 'Homo Sapiens',
          'hmdmc_not_required_confirmed_by' => 'dirk',
        })
    end
    it "should correct set the fields on the nonhuman material" do
      expect(@lw.contents['2']).to eq({
          'scientific_name' => 'Mouse',
        })
    end
  end

  describe "#clear_hmdmc" do
    before do
      @lw = make_labware(1, 2, false, false, { contents: { "1" => make_contents(true, hmdmc_user: 'jeff'), "2" => make_contents(false, hmdmc: "99/999")}})

      @lw.clear_hmdmc
    end
    it "should correct set the fields on the human material" do
      expect(@lw.contents['1']).to eq({
          'scientific_name' => 'Homo Sapiens',
        })
    end
    it "should correct set the fields on the nonhuman material" do
      expect(@lw.contents['2']).to eq({
          'scientific_name' => 'Mouse',
        })
    end
  end

  describe "#first_hmdmc" do
    context "when the labware has no contents" do
      before do
        @lw = make_labware(1, 2, false, false, { contents: nil })
      end
      it "should return nil" do
        expect(@lw.first_hmdmc).to be_nil
      end
    end
    context "when the labware has human contents but no HMDMC" do
      before do
        @lw = make_labware(1, 2, false, false, { contents: {"1" => make_contents(true) } })
      end
      it "should return nil" do
        expect(@lw.first_hmdmc).to be_nil
      end
    end
    context "when the labware has human contents with an HMDMC" do
      before do
        @lw = make_labware(1, 2, false, false, { contents: {"1" => make_contents(true, hmdmc: '12/345') } })
      end
      it "should return the HMDMC" do
        expect(@lw.first_hmdmc).to eq('12/345')
      end
    end
  end

  describe "#confirmed_no_hmdmc?" do
    context "when the labware has no contents" do
      before do
        @lw = make_labware(1, 2, false, false, { contents: nil })
      end
      it "should return false" do
        expect(@lw.confirmed_no_hmdmc?).to be_falsey
      end
    end
    context "when the labware has human contents but not confirmed no HMDMC" do
      before do
        @lw = make_labware(1, 2, false, false, { contents: {"1" => make_contents(true) } })
      end
      it "should return false" do
        expect(@lw.confirmed_no_hmdmc?).to be_falsey
      end
    end
    context "when the labware has human contents and confirmed no HMDMC" do
      before do
        @lw = make_labware(1, 2, false, false, { contents: {"1" => make_contents(true, not_required: 'dirk') } })
      end
      it "should return true" do
        expect(@lw.confirmed_no_hmdmc?).to be_truthy
      end
    end
  end
end
