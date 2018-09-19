require "rails_helper"

RSpec.describe ManifestHelper, type: :helper do

  describe "#supply_labware_type" do

    context "when the Manifest does not need Labware supplied" do

      before do
        labware_type = create(:plate_labware_type)
        @manifest = create(:manifest, labware_type: labware_type, supply_labwares: false)
      end

      it "should return 'Label for labware type'" do
        expect(helper.supply_labware_type(@manifest)).to eq 'Label for Plate'
      end

    end

    context "when the Manifest does need Labware supplied" do

      before do
        labware_type = create(:plate_labware_type)
        @manifest = create(:manifest, labware_type: labware_type, supply_labwares: true)
      end

      it "should return the labware type name" do
        expect(helper.supply_labware_type(@manifest)).to eq 'Plate'
      end

    end

    context "when the Manifest needs decappers" do

      before do
        labware_type = create(:rack_labware_type)
        @manifest = create(:manifest, labware_type: labware_type, supply_labwares: true, supply_decappers: true)
      end

      it "should return the labware type name with decappers" do
        expect(helper.supply_labware_type(@manifest)).to eq 'Rack with decappers'
      end

    end
  end

end