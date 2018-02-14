require 'rails_helper'
require 'webmock/rspec'

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
    allow(submission).to receive(:update_attributes!)
    submission
  end

  let(:flash) { Hash.new }

  let(:service) { EthicsService.new(submission, flash) }

  let(:user) { 'dirk@sanger.ac.uk' }

  describe '#update' do

    def stub_ehmdmc(hmdmc, status_code)
      stub_request(
        :get,
        "#{Rails.configuration.ehmdmc_url}?hmdmc=#{hmdmc.sub('/','_')}")
          .to_return(status: status_code)
    end

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

    before do
      stub_ehmdmc('12/345', 200)
      stub_ehmdmc('12/999', 404)
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
      end

      it 'does not save the labware' do
        expect(submission.labwares.first).not_to have_received(:save!)
      end

      it 'does not update the submission' do
        expect(submission).not_to have_received(:update_attributes!)
      end
    end

    context 'when not-required is not specified' do
      before do
        run({})
      end

      it 'produces an error' do
        expect_error(/either.*hmdmc/i)
      end

      it 'does not set hmdmc information' do
        expect(submission).not_to have_received(:set_hmdmc_not_required)
      end

      it 'does not save the labware' do
        expect(submission.labwares.first).not_to have_received(:save!)
      end

      it 'does not update the submission' do
        expect(submission).not_to have_received(:update_attributes!)
      end
    end

    context 'when argument is zero' do
      before do
        run(confirm_hmdmc_not_required: '0')
      end

      it 'produces an error' do
        expect_error(/either.*hmdmc/i)
      end

      it 'does not set hmdmc information' do
        expect(submission).not_to have_received(:set_hmdmc_not_required)
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

      it 'saves the labware' do
        submission.labwares.each { |lw| expect(lw).to have_received(:save!) }
      end

      it 'updates the submission status' do
        expect(submission).to have_received(:update_attributes!).with(status: 'dispatch')
      end
    end
  end
end
