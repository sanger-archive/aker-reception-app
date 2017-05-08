require 'rails_helper'

RSpec.describe MaterialReception, type: :model do

  before do
    @labware = create(:labware, print_count: 1, barcode: 'AKER-42')
    @reception = create(:material_reception, labware_id: @labware.id)
  end

  describe "#labware" do
    it "should return the labware" do
      expect(@reception.labware).to eq @labware
    end
  end

  describe "#barcode_value" do
    it "should return the labware barcode" do
      expect(@reception.barcode_value).to eq @labware.barcode
    end
  end

  describe "#barcode_value=" do
    before do
      @other_labware = create(:labware, print_count: 1, barcode: 'AKER-616')
    end

    it "should link the reception to the labware" do
      @reception.barcode_value=@other_labware.barcode
      expect(@reception.labware).to eq(@other_labware)
    end
  end

  describe "#validate_barcode_printed" do
    context "when labware has been printed" do
      it "should not add an error" do
        @reception.validate_barcode_printed
        expect(@reception.errors).to be_empty
      end
    end

    context "when labware has not been printed" do
      before do
        @labware.update_attributes(print_count: 0)
      end
      it "should add an error" do
        @reception.validate_barcode_printed
        expect(@reception.errors.count).to eq 1
        expect(@reception.errors.first[1]).to include('printed')
      end
    end
  end

  describe "#labware_already_received?" do
    context "when labware has been received" do
      before do
        # Unpersisted, so this won't trigger a match in labware_already_received?
        @new_reception = build(:material_reception, labware_id: @labware.id)
      end
      it "should return true" do
        expect(@new_reception.labware_already_received?).to eq true
      end
    end

    context "when labware has been received" do
      before do
        @labware = create(:labware, print_count: 1, barcode: 'AKER-616')
        # Unpersisted, so this won't trigger a match in labware_already_received?
        @new_reception = build(:material_reception, labware_id: @labware.id)
      end
      it "should return false" do
        expect(@new_reception.labware_already_received?).to eq false
      end
    end
  end

  describe "#all_received?" do
    before do
      @labware2 = create(:labware, labware_index: 2, print_count: 1, barcode: 'AKER-43', material_submission: @labware.material_submission)
      # A piece of labware from another submission:
      @labware_x = create(:labware, barcode: 'AKER-616')
    end

    context "when all labware are received" do
      before do
        @reception2 = create(:material_reception, labware_id: @labware2.id)
      end
      it "should return true" do
        expect(@reception.all_received?).to eq true
        expect(@reception2.all_received?).to eq true
      end
    end

    context "when not all labware are received" do
      it "should return false" do
        expect(@reception.all_received?).to eq false
      end
    end

    context "when no labware are received" do
      before do
        # Unpersisted, so this won't match as labware-received
        @reception_x = build(:material_reception, labware_id: @labware_x.id)
      end
      it "should return false" do
        expect(@reception_x.all_received?).to eq false
      end
    end
  end

  describe "#presenter" do
    def expect_error(rec, text)
      errors = rec.presenter
      expect(errors[:error]).not_to be_nil
      expect(errors[:error]).to include(text)
    end

    context "when labware has no barcode" do
      before do
        @reception.labware_id = nil
        allow(@reception).to receive(:invalid?).and_return(true)
      end
      it "should return an error" do
        expect_error(@reception, 'barcode')
      end
    end

    context "when labware has already been received" do
      before do
        allow(@reception).to receive(:invalid?).and_return(true)
      end
      it "should return an error" do
        expect_error(@reception, 'already received')
      end
    end

    context "when labware has not been printed" do
      before do
        @new_labware = create(:labware, print_count: 0, barcode: 'AKER-616')
        @new_reception = build(:material_reception, labware_id: @new_labware.id)
        allow(@new_reception).to receive(:invalid?).and_return(true)
      end
      it "should return an error" do
        expect_error(@new_reception, 'printed')
      end
    end

    context "when reception is valid" do
      it "should present the reception" do
        expect(@reception.presenter).to eq(
          {
            labware: { barcode: @labware.barcode },
            created_at: @reception.created_at,
            updated_at: @reception.updated_at,
          }
        )
      end
    end
  end
end
