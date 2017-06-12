require 'rails_helper'

RSpec.describe :ethics_service do
  let(:submission) do
    lw = double('labware')
    allow(lw).to receive(:save!)
    submission = double(
      'material_submission',
      labwares: [lw],
      any_human_material?: true,
    )
    allow(submission).to receive(:set_hmdmc_not_required)
    allow(submission).to receive(:set_hmdmc)
    allow(submission).to receive(:update_attributes!)
    submission
  end

  let(:flash) { Hash.new }

  let(:service) { EthicsService.new(submission, flash) }

  let(:user) { 'dirk@sanger.ac.uk' }

  describe '#update' do

    def run(params)
      @result = service.update(params, user)
    end

    def expect_error(text)
      expect(@result).to be_falsey
      expect(flash[:error]).to be_present
      expect(flash[:error]).to match(text)
    end

    def expect_success
      expect(@result).to be_truthy
      expect(flash[:error]).to be_nil
    end

    context 'when the submission has no human material' do
      before do
        allow(submission).to receive(:any_human_material?).and_return(false)
        run(confirm_hmdmc_not_required: '1')
      end

      it 'produces an error' do
        expect_error(/human material/i)
      end

      it 'does not set hmdmc information' do
        expect(submission).not_to have_received(:set_hmdmc_not_required)
        expect(submission).not_to have_received(:set_hmdmc)
      end

      it 'does not save the labware' do
        expect(submission.labwares.first).not_to have_received(:save!)
      end

      it 'does not update the submission' do
        expect(submission).not_to have_received(:update_attributes!)
      end
    end

    context 'when the hmdmc and "not required" are both specified' do
      before do
        run(confirm_hmdmc_not_required: '1', hmdmc_1: '17', hmdmc_2: '123')
      end

      it 'produces an error' do
        expect_error(/both.*choose/i)
      end

      it 'does not set hmdmc information' do
        expect(submission).not_to have_received(:set_hmdmc_not_required)
        expect(submission).not_to have_received(:set_hmdmc)
      end

      it 'does not save the labware' do
        expect(submission.labwares.first).not_to have_received(:save!)
      end

      it 'does not update the submission' do
        expect(submission).not_to have_received(:update_attributes!)
      end
    end

    context 'when part of the HMDMC is missing' do
      before do
        run(hmdmc_1: '17')
      end

      it 'produces an error' do
        expect_error(/both.*hmdmc/i)
      end

      it 'does not set hmdmc information' do
        expect(submission).not_to have_received(:set_hmdmc_not_required)
        expect(submission).not_to have_received(:set_hmdmc)
      end

      it 'does not save the labware' do
        expect(submission.labwares.first).not_to have_received(:save!)
      end

      it 'does not update the submission' do
        expect(submission).not_to have_received(:update_attributes!)
      end
    end

    context 'when neither hmdmc nor not-required is specified' do
      before do
        run({})
      end

      it 'produces an error' do
        expect_error(/either.*hmdmc/i)
      end

      it 'does not set hmdmc information' do
        expect(submission).not_to have_received(:set_hmdmc_not_required)
        expect(submission).not_to have_received(:set_hmdmc)
      end

      it 'does not save the labware' do
        expect(submission.labwares.first).not_to have_received(:save!)
      end

      it 'does not update the submission' do
        expect(submission).not_to have_received(:update_attributes!)
      end
    end

    context 'when arguments are zero and empty respectively' do
      before do
        run(confirm_hmdmc_not_required: '0', hmdmc_1: '', hmdmc_2: '')
      end

      it 'produces an error' do
        expect_error(/either.*hmdmc/i)
      end

      it 'does not set hmdmc information' do
        expect(submission).not_to have_received(:set_hmdmc_not_required)
        expect(submission).not_to have_received(:set_hmdmc)
      end

      it 'does not save the labware' do
        expect(submission.labwares.first).not_to have_received(:save!)
      end

      it 'does not update the submission' do
        expect(submission).not_to have_received(:update_attributes!)
      end
    end

    context 'when confirmed HMDMC not required' do
      before do
        run(confirm_hmdmc_not_required: '1')
      end

      it 'succeeds' do
        expect_success
      end

      it 'sets HMDMC not required' do
        expect(submission).to have_received(:set_hmdmc_not_required).with(user)
      end

      it 'does not set an HMDMC' do
        expect(submission).not_to have_received(:set_hmdmc)
      end

      it 'saves the labware' do
        submission.labwares.each { |lw| expect(lw).to have_received(:save!) }
      end

      it 'updates the submission status' do
        expect(submission).to have_received(:update_attributes!).with(status: 'dispatch')
      end
    end

    context 'when confirmed HMDMC not required, and HMDMC is empty' do
      before do
        run(confirm_hmdmc_not_required: '1', hmdmc_1: '', hmdmc_2: '')
      end

      it 'succeeds' do
        expect_success
      end

      it 'sets HMDMC not required' do
        expect(submission).to have_received(:set_hmdmc_not_required).with(user)
      end

      it 'does not set an HMDMC' do
        expect(submission).not_to have_received(:set_hmdmc)
      end

      it 'saves the labware' do
        submission.labwares.each { |lw| expect(lw).to have_received(:save!) }
      end

      it 'updates the submission status' do
        expect(submission).to have_received(:update_attributes!).with(status: 'dispatch')
      end
    end

    context 'when HMDMC supplied' do
      before do
        run(hmdmc_1: '12', hmdmc_2: '345')
      end

      it 'succeeds' do
        expect_success
      end

      it 'does not set the HMDMC not required' do
        expect(submission).not_to have_received(:set_hmdmc_not_required)
      end

      it 'sets the HMDMC' do
        expect(submission).to have_received(:set_hmdmc).with('12/345', user)
      end

      it 'saves the labware' do
        submission.labwares.each { |lw| expect(lw).to have_received(:save!) }
      end

      it 'updates the submission status' do
        expect(submission).to have_received(:update_attributes!).with(status: 'dispatch')
      end
    end

    context 'when HMDMC supplied and not-required is zero' do
      before do
        run(confirm_hmdmc_not_required: '0', hmdmc_1: '12', hmdmc_2: '345')
      end

      it 'succeeds' do
        expect_success
      end

      it 'does not set the HMDMC not required' do
        expect(submission).not_to have_received(:set_hmdmc_not_required)
      end

      it 'sets the HMDMC' do
        expect(submission).to have_received(:set_hmdmc).with('12/345', user)
      end

      it 'saves the labware' do
        submission.labwares.each { |lw| expect(lw).to have_received(:save!) }
      end

      it 'updates the submission status' do
        expect(submission).to have_received(:update_attributes!).with(status: 'dispatch')
      end
    end
  end
end
