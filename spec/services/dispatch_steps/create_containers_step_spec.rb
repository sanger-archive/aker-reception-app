require 'rails_helper'
require 'dispatch_steps/create_containers_step'

RSpec.describe :create_containers_step do

  def make_slots
    'A:1 A:2 A:3 B:1 B:2 B:3'.split.map do |address|
      slot = double('slot', address: address)
      allow(slot).to receive(:material_id=)
      slot
    end
  end

  def made_up_barcode
    @barcode_counter += 1
    "AKER-#{@barcode_counter}"
  end

  def made_up_uuid
    SecureRandom.uuid
  end

  def make_container
    container = double("container", slots: make_slots, barcode: made_up_barcode, id: made_up_uuid)
    allow(container).to receive(:save)
    container
  end

  def stub_matcon
    @barcode_counter = 0
    @containers = []

    allow(MatconClient::Container).to receive(:destroy).and_return(true)

    allow(MatconClient::Container).to receive(:create) do |args|
      container = make_container
      @containers.push(container)
      container
    end
  end

  def make_labware(i)
    lw = double(:labware, labware_index: i, num_of_rows: 2, num_of_cols: 3, row_is_alpha: true, col_is_alpha: false)
    allow(lw).to receive(:update_attributes).and_return(true)
    allow(lw).to receive(:container_id).and_return(nil)
    allow(lw).to receive(:contents).and_return({
      "A:1" => {
        "gender" => "male",
        "id" => made_up_uuid
      }
    })
    lw
  end

  def make_submission
    labwares = (1..2).map { |i| make_labware(i) }
    @submission = double(:material_submission, labwares: labwares)
  end

  def make_step
    @step = DispatchSteps::CreateContainersStep.new(make_submission)
  end

  describe "#up" do
    context "when labwares need containers creating" do
      before do
        stub_matcon
        make_step
        @step.up
      end

      it "should have created containers" do
        expect(@containers.length).to eq 2
        expect(MatconClient::Container).to have_received(:create).with({
          num_of_rows: 2, num_of_cols: 3, row_is_alpha: true, col_is_alpha: false, print_count: 0
        }).twice
      end

      it "should have updated the labware" do
        (0...2).each do |i|
          expect(@submission.labwares[i]).to have_received(:update_attributes).with({
            barcode: @containers[i].barcode,
            container_id: @containers[i].id
          })
        end
      end

      it "should have added the materials to the containers" do
        (0...2).each do |i|
          @submission.labwares[i].contents.each do |address, bio_data|
            slot = @containers[i].slots.select { |s| s.address == address }.first
            expect(slot).to have_received(:material_id=).with(bio_data['id'])
          end
          expect(@containers[i]).to have_received(:save)
        end
      end
    end

    context "when some labwares already have container ids" do
      before do
        stub_matcon
        make_step
        allow(@submission.labwares[0]).to receive(:container_id).and_return(made_up_uuid)
        @step.up
      end

      it "should create containers for labware that don't already have one" do
        expect(MatconClient::Container).to have_received(:create).with({
          num_of_rows: 2, num_of_cols: 3, row_is_alpha: true, col_is_alpha: false, print_count: 0
        }).once
        expect(@containers.length).to eq 1
      end

      it "should have added the materials to the new container" do
        lw = @submission.labwares[1]
        container = @containers[0]
        lw.contents.each do |address, bio_data|
          slot = container.slots.select { |s| s.address == address }.first
          expect(slot).to have_received(:material_id=).with(bio_data['id'])
        end
        expect(container).to have_received(:save)
      end

      it "should not have updated the labwares that already had a container id" do
        expect(@submission.labwares[0]).not_to have_received(:update_attributes)
      end

      it "should have updated the labware that didn't have a container id" do
        expect(@submission.labwares[1]).to have_received(:update_attributes).with({
          barcode: @containers[0].barcode,
          container_id: @containers[0].id
        })
      end
    end

    context "when all labwares already have container ids" do
      before do
        stub_matcon
        make_step
        @submission.labwares.each do |lw|
          allow(lw).to receive(:container_id).and_return(made_up_uuid)
        end
        @step.up
      end

      it "should not create any containers" do
        expect(MatconClient::Container).not_to have_received(:create)
        expect(@containers).to be_empty
      end
      it "should not have updated the labwares" do
        @submission.labwares.each do |lw|
          expect(lw).not_to have_received(:update_attributes)
        end
      end
    end
  end

  describe "#down" do
    context "when labwares have container ids" do
      before do
        stub_matcon
        make_step
        @submission.labwares.each do |lw|
          allow(lw).to receive(:container_id).and_return(made_up_uuid)
        end
        @step.down
      end

      it "should have destroyed the containers" do
        @submission.labwares.each do |lw|
          expect(MatconClient::Container).to have_received(:destroy).with(lw.container_id)
        end
      end

      it "should have updated the labware" do
        @submission.labwares.each do |lw|
          expect(lw).to have_received(:update_attributes).with({
            barcode: nil, container_id: nil
          })
        end
      end
    end

    context "when some labwares have container ids" do
      before do
        stub_matcon
        make_step
        allow(@submission.labwares[0]).to receive(:container_id).and_return(made_up_uuid)
        @step.down
      end

      it "should have destroyed the containers where present" do
        lw = @submission.labwares[0]
        expect(MatconClient::Container).to have_received(:destroy).once
        expect(MatconClient::Container).to have_received(:destroy).with(lw.container_id)
      end

      it "should have updated the labware that had container ids" do
        expect(@submission.labwares[0]).to have_received(:update_attributes).with({
          barcode: nil, container_id: nil
        })
      end

      it "should not have updated the labware that had no container ids" do
        expect(@submission.labwares[1]).not_to have_received(:update_attributes)
      end
    end

    context "when no labwares have container ids" do
      before do
        stub_matcon
        make_step
        @step.down
      end

      it "should not have destroyed any containers" do
        expect(MatconClient::Container).not_to have_received(:destroy)
      end

      it "should not have updated the labware that had no container ids" do
        @submission.labwares.each do |lw|
          expect(lw).not_to have_received(:update_attributes)
        end
      end
    end
  end

end