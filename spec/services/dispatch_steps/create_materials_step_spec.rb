# frozen_string_literal: true

require 'rails_helper'
require 'dispatch_steps/create_materials_step'

RSpec.describe :create_materials_step do
  def stub_matcon
    @materials = []
    allow(MatconClient::Material).to receive(:create) do
      m = double('material', id: SecureRandom.uuid)
      @materials.push(m)
      m
    end
    allow(MatconClient::Material).to receive(:destroy).and_return(true)
  end

  def build_contents(bio_ids)
    contents = {}
    i = 1
    bio_ids.each do |bio_id|
      contents[i.to_s] = {
        'gender' => 'female'
      }
      contents[i.to_s]['id'] = bio_id if bio_id
      i += 1
    end
    contents
  end

  def make_labware(has_ids)
    bio_ids = has_ids.map { |has_id| has_id ? SecureRandom.uuid : nil }
    lw = double(:labware, original_bio_ids: bio_ids, contents: build_contents(bio_ids))
    allow(lw).to receive(:update_attributes).and_return(true)
    lw
  end

  def make_submission(labware_bio_ids)
    labwares = labware_bio_ids.map { |bio_ids| make_labware(bio_ids) }
    contact = double('contact', email: 'testing@email')
    owner = double('contact', email: 'contact@email')
    # The 'contact' for a siubmission has most recently been renamed to 'Sample Guardian' while the
    # 'owner_email' refers to the owner of the submission. Within materials, the 'owner_email' is
    # used as the 'submitter_id' indicating who submitted the materials.
    @submission = double(:material_submission, labwares: labwares,
                                               contact: contact,
                                               owner_email: owner.email)
  end

  def make_step(labware_bio_ids)
    @step = DispatchSteps::CreateMaterialsStep.new(make_submission(labware_bio_ids))
  end

  describe '#up' do
    context 'when labwares contain bio ids' do
      before do
        stub_matcon
        make_step([[true, true], [true]])
        @step.up
      end

      it 'should not create materials' do
        expect(MatconClient::Material).not_to have_received(:create)
      end

      it 'should not update labware' do
        @submission.labwares.each do |lw|
          expect(lw).not_to have_received(:update_attributes)
        end
      end
    end

    context 'when labwares contain some bio ids' do
      before do
        stub_matcon
        make_step([[true, false], [true]])
        @step.up
      end

      it 'should create materials only when necessary' do
        expect(MatconClient::Material).to have_received(:create).with(
          hash_including(owner_id: @submission.contact.email,
                         submitter_id: @submission.owner_email)
        )
        expect(@materials.length).to eq 1
      end

      it 'should update some labware' do
        expect(@submission.labwares[0]).to have_received(:update_attributes).with(
          contents: @submission.labwares[0].contents
        )
        expect(@submission.labwares[1]).not_to have_received(:update_attributes)
      end
    end

    context 'when labwares contain no bio ids' do
      before do
        stub_matcon
        make_step([[false, false], [false]])
        @step.up
      end

      it 'should create materials' do
        expect(MatconClient::Material).to have_received(:create).with(
          hash_including(owner_id: @submission.contact.email)
        ).thrice
        expect(@materials.length).to eq 3
      end

      it 'should update the labware' do
        expect(@submission.labwares[0]).to have_received(:update_attributes) do |data|
          contents = data[:contents]
          expect(contents['1']['id']).to eq @materials[0].id
          expect(contents['2']['id']).to eq @materials[1].id
        end

        expect(@submission.labwares[1]).to have_received(:update_attributes) do |data|
          contents = data[:contents]
          expect(contents['1']['id']).to eq @materials[2].id
        end
      end
    end
  end

  describe '#down' do
    context 'when labwares contain no bio ids' do
      before do
        stub_matcon
        make_step([[false, false], [false]])
        @step.down
      end

      it 'should not destroy materials' do
        expect(MatconClient::Material).not_to have_received(:destroy)
      end

      it 'should not update labware' do
        @submission.labwares.each do |labware|
          expect(labware).not_to have_received(:update_attributes)
        end
      end
    end

    context 'when labwares contain bio ids' do
      before do
        stub_matcon
        make_step([[true, true], [true]])
        @step.down
      end

      it 'should destroy the materials' do
        @submission.labwares.each do |labware|
          labware.original_bio_ids.each do |bio_id|
            expect(MatconClient::Material).to have_received(:destroy).with(bio_id)
          end
        end
      end

      it 'should update the labware' do
        expect(@submission.labwares[0]).to have_received(:update_attributes) do |data|
          contents = data[:contents]
          expect(contents['1']['id']).to be_nil
          expect(contents['2']['id']).to be_nil
        end

        expect(@submission.labwares[1]).to have_received(:update_attributes) do |data|
          contents = data[:contents]
          expect(contents['1']['id']).to be_nil
        end
      end
    end

    context 'when labwares contain some bio ids' do
      before do
        stub_matcon
        make_step([[false, true], [false]])
        @step.down
      end

      it 'should destroy the material' do
        expect(MatconClient::Material).to have_received(:destroy).once
        expect(MatconClient::Material).to have_received(:destroy).with(
          @submission.labwares[0].original_bio_ids[1]
        )
      end

      it 'should update the labware that had some materials' do
        expect(@submission.labwares[0]).to have_received(:update_attributes) do |data|
          contents = data[:contents]
          expect(contents['2']['id']).to be_nil
        end
      end

      it 'should not update the labware that had no materials' do
        expect(@submission.labwares[1]).not_to have_received(:update_attributes)
      end
    end
  end
end
