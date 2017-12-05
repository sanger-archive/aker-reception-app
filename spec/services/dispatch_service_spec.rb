require 'rails_helper'

RSpec.describe :dispatch_service do
  def make_step(up_succeeds = true, down_succeeds = true)
    step = double('step')
    up = allow(step).to receive(:up)
    up.and_raise('up failed') unless up_succeeds
    down = allow(step).to receive(:down)
    down.and_raise('down failed') unless down_succeeds
    step
  end

  setup do
    @service = DispatchService.new
  end

  context 'when all steps succeed' do
    before do
      @steps = [make_step, make_step]
      @result = @service.process(@steps)
    end
    it 'should have run up each step' do
      @steps.each { |step| expect(step).to have_received(:up) }
    end
    it 'should not have run down the steps' do
      @steps.each { |step| expect(step).not_to have_received(:down) }
    end
    it 'should return true' do
      expect(@result).to eq true
    end
  end

  context 'when rollback succeeds' do
    before do
      @steps = [make_step, make_step(false, true), make_step]
      @result = @service.process(@steps)
    end
    it 'should have run up steps until a fail' do
      expect(@steps[0]).to have_received(:up)
      expect(@steps[1]).to have_received(:up)
    end
    it 'should not have run up any further after a fail' do
      expect(@steps[2]).not_to have_received(:up)
    end
    it 'should have run down the steps that ran up' do
      expect(@steps[0]).to have_received(:down)
      expect(@steps[1]).to have_received(:down)
    end
    it 'should not have run down any later steps' do
      expect(@steps[2]).not_to have_received(:down)
    end
    it 'should return false' do
      expect(@result).to eq false
    end
  end

  context 'when rollback fails' do
    before do
      @steps = [make_step, make_step(true, false), make_step(false, true)]
      begin
        @service.process(@steps)
        @exception = nil
      rescue StandardError => e
        @exception = e
      end
    end
    it 'should have run up the steps' do
      expect(@steps[0]).to have_received(:up)
      expect(@steps[1]).to have_received(:up)
      expect(@steps[2]).to have_received(:up)
    end
    it 'should have run down until a fail' do
      expect(@steps[2]).to have_received(:down)
      expect(@steps[1]).to have_received(:down)
    end
    it 'should have raised an exception' do
      expect(@exception).not_to be_nil
    end
  end
end
