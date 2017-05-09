require 'rails_helper'
require "rspec/json_expectations"


RSpec.describe MaterialReception, type: :model do
  describe "#build" do
    it "returns a validation message when the barcode does not exist" do
      labware = build :labware_with_barcode_and_material_submission
      expect { create :material_reception, labware_id: labware.id }.to raise_error
    end

    it "returns a validation message when the barcode has been received already" do
      labware = create(:labware_with_barcode_and_material_submission, print_count: 1)
      create :material_reception, labware_id: labware.id
      expect { create :material_reception, labware_id: labware.id }.to raise_error
    end

    it "returns a validation message when the barcode has not been printed yet" do
      labware = create(:labware_with_barcode_and_material_submission)
      expect { create :material_reception, labware_id: labware.id }.to raise_error
    end

    it "creates the reception object when the barcode has not been received and it has been printed" do
      labware = create(:labware_with_barcode_and_material_submission, print_count: 1)
      r = create :material_reception, labware_id: labware.id
      expect(r.valid?).to eq(true)
    end    
  end

  describe "#presenter" do
    it "returns an error message when the barcode does not exist" do
      labware = build :labware_with_barcode_and_material_submission
      r = build :material_reception, labware_id: labware.id
      expect(r.presenter).to include_json({:error => 'Cannot find the barcode'})
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
        :error => 'This barcode has not been printed yet. Please contact the administrator'
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
end
