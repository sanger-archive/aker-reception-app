require 'rails_helper'
require 'dispatch_steps/create_sets_step'

RSpec.describe :create_sets_step do
  def make_uuid
    SecureRandom.uuid
  end

  def make_set
    s = double('set', id: make_uuid)
    allow(s).to receive(:destroy).and_return(true)
    allow(s).to receive(:set_materials).and_return(true)
    allow(s).to receive(:update_attributes).and_return(true)
    @sets.push(s)
    s
  end

  def stub_sets
    @sets = []
    allow(SetClient::Set).to receive(:create) { make_set }
    allow(SetClient::Set).to receive(:find) do |set_id|
      @sets.select { |s| s.id==set_id }
    end
  end

  def make_labware
    contents = {
      "1" => { "id" => make_uuid },
      "2" => { "id" => make_uuid },
    }
    double(:labware, contents: contents)
  end

  def make_submission(set_id)
    labwares = [make_labware, make_labware]
    contact = double('contact', email: 'jeff')
    @submission = double(:material_submission, id: 537, labwares: labwares, set_id: set_id, contact: contact)
    allow(@submission).to receive(:set_id=)
    allow(@submission).to receive(:update_attributes)
    @submission
  end

  def make_step(set_id)
    make_submission(set_id)
    @step = DispatchSteps::CreateSetsStep.new(@submission)
  end

  describe "#up" do
    context "when submission has no set id" do
      before do
        stub_sets
        make_step(nil)
        @step.up
      end

      it "should create a set" do
        expect(SetClient::Set).to have_received(:create).with(
          name: "Submission #{@submission.id}"
        )
        expect(@sets.length).to eq 1
      end
      it "should update the submission with the set id" do
        expect(@submission).to have_received(:update_attributes).with(set_id: @sets.first.id)
      end
      it "should add the materials to the set" do
        uuids = []
        @submission.labwares.each do |lw|
          lw.contents.each do |address, bio_data|
            uuids.push(bio_data['id'])
          end
        end
        expect(@sets.first).to have_received(:set_materials).with(uuids)
      end
      it "should lock the set" do
        expect(@sets.first).to have_received(:update_attributes).with({
          locked: true, owner_id: @submission.contact.email})
      end
    end

    context "when submission already has a set id" do
      before do
        stub_sets
        make_step(make_uuid)
        @step.up
      end

      it "should not create a set" do
        expect(SetClient::Set).not_to have_received(:create)
        expect(@sets).to be_empty
      end
      it "should not update the submission" do
        expect(@submission).not_to have_received(:update_attributes)
      end
    end
  end

  describe "#down" do
    context "when submission has a set id" do
      before do
        stub_sets
        @set = make_set
        make_step(@set.id)
        @step.down
      end

      it "should find the set" do
        expect(SetClient::Set).to have_received(:find).with(@submission.set_id)
      end
      it "should destroy the set" do
        expect(@set).to have_received(:destroy)
      end
      it "should update the submission" do
        expect(@submission).to have_received(:update_attributes).with(set_id: nil)
      end
    end

    context "when submission has no set id" do
      before do
        stub_sets
        make_step(nil)
        @step.down
      end

      it "should not try and find any set" do
        expect(SetClient::Set).not_to have_received(:find)
      end

      it "should not update the submission" do
        expect(@submission).not_to have_received(:update_attributes)
      end
    end
  end
end
