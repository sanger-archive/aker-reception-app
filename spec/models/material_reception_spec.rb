require 'rails_helper'
require "rspec/json_expectations"


RSpec.describe MaterialReception, type: :model do
  describe "Validation" do
    it "returns a validation message when the barcode does not exist" do
      labware = build :labware_with_barcode_and_material_submission
      expect { create :material_reception, labware_id: labware.id }.to raise_error(ActiveRecord::RecordInvalid)
    end

    it "returns a validation message when the barcode has been received already" do
      labware = create(:labware_with_barcode_and_material_submission, print_count: 1)
      create :material_reception, labware_id: labware.id
      expect { create :material_reception, labware_id: labware.id }.to raise_error(ActiveRecord::RecordInvalid)
    end

    it "returns a validation message when the barcode has not been printed yet" do
      labware = create(:labware_with_barcode_and_material_submission)
      expect { create :material_reception, labware_id: labware.id }.to raise_error(ActiveRecord::RecordInvalid)
    end

    it "creates the reception object when the barcode has not been received and it has been printed" do
      labware = create(:labware_with_barcode_and_material_submission, print_count: 1)
      r = create :material_reception, labware_id: labware.id
      expect(r.valid?).to eq(true)
    end

    it "is valid when labware has been printed" do
      labware = build(:printed_labware)
      expect(build(:material_reception, labware: labware)).to be_valid
    end

    it "is invalid when labware has not been printed" do
      labware = build(:labware, print_count: 0)
      expect(build(:material_reception, labware: labware)).to_not be_valid
    end

    it "is invalid when labware has already been received" do
      labware = create(:printed_labware)
      create(:material_reception, labware: labware)
      expect(build(:material_reception, labware: labware)).to_not be_valid
    end

    it "is valid when labware has not been receieved" do
      labware = create(:printed_labware)
      expect(build(:material_reception, labware: labware)).to be_valid
    end
  end

  describe "#presenter" do
    it "returns an error message when the barcode does not exist" do
      labware = build :labware_with_barcode_and_material_submission
      r = build :material_reception, labware_id: labware.id
      expect(r.presenter).to include_json({:error => 'Labware must exist'})
    end

    it "returns an error message when the barcode has been received already" do
      labware = create(:labware_with_barcode_and_material_submission, print_count: 1)
      create :material_reception, labware_id: labware.id
      r = build :material_reception, labware_id: labware.id
      expect(r.presenter).to include_json({:error => 'Labware already received'})
    end

    it "returns an error message when the barcode has not been printed yet" do
      labware = create(:labware_with_barcode_and_material_submission)
      r = build :material_reception, labware_id: labware.id
      expect(r.presenter).to include_json({
        :error => 'Labware barcode has not been printed. Please contact the administrator.'
      })
    end

    it "returns json with the info for the barcode when the barcode has not been received and it has been printed" do
      labware = create(:labware_with_barcode_and_material_submission, print_count: 1)
      r = build :material_reception, labware_id: labware.id
      expect(r.presenter).to include_json({
        :labware => { :barcode => labware.barcode }
      })
    end
  end

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

    context "when reception has no labware" do
      it "should return an error" do
        expect_error(build(:material_reception), 'Labware')
      end
    end

    context "when labware has already been received" do
      it "should return an error" do
        labware = create(:printed_labware)
        create(:material_reception, labware: labware)
        expect_error(build(:material_reception, labware: labware), 'already received')
      end
    end

    context "when labware has not been printed" do
      it "should return an error" do
        labware = create(:labware)
        expect_error(build(:material_reception, labware: labware), 'printed')
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
