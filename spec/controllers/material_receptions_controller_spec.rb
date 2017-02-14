require 'rails_helper'

RSpec.describe MaterialReceptionsController, type: :controller do
  describe "When scanning a barcode" do
    setup do
      @labware = FactoryGirl.create(:labware)
      @submission = FactoryGirl.create(:material_submission)
      @submission.labwares << @labware
    end

    it "does not add the barcode to the list if the barcode does not exist" do
      count = MaterialReception.all.count
      post :create, { :material_reception => {:barcode_value => 'NOT_EXISTS'}}
      MaterialReception.all.reload
      expect(MaterialReception.all.count).to eq(count)
    end

    it "does not add the barcode to the list if the barcode has already been received" do
      MaterialReception.create(:labware => @labware)
      count = MaterialReception.all.count
      post :create, { :material_reception => {:barcode_value => @labware.barcode.value}}
      MaterialReception.all.reload
      expect(MaterialReception.all.count).to eq(count)
    end

    it "does not add the barcode to the list if the barcode has not been printed" do
      @labware.barcode.update_attributes(print_count: 0)
      count = MaterialReception.all.count
      post :create, { :material_reception => {:barcode_value => @labware.barcode.value}}
      MaterialReception.all.reload
      expect(MaterialReception.all.count).to eq(count)
    end

    it "adds the barcode to the list if the barcode exists and has not been received yet" do
      count = MaterialReception.all.count
      @labware.barcode.update_attributes(print_count: 1)
      post :create, { :material_reception => {:barcode_value => @labware.barcode.value }}
      MaterialReception.all.reload
      expect(MaterialReception.all.count).to eq(count+1)
    end
  end
end
