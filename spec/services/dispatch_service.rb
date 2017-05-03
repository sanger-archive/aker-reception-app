require 'rails_helper'


class Service
  def up
    is_successful?
  end
  def down
    is_successful?
  end
end

class SuccessfulService < Service
  def is_successful?
    true
  end  
end

class FailService < Service
  def is_successful?
    false
  end
end

class FaultyRollableBack < Service
  def is_successful?
    false
  end
  def down
    true
  end
end

class FaultyNotRollableBack < Service
  def is_successful?
    false
  end
  def down
    false
  end
end

RSpec.describe :dispatch_service do
  setup do
    @dispatch = DispatchService.new
  end

  shared_examples "a list of rollable back services" do
    it "tries to execute the successful services until the faulty one and then rolls back in reverse order" do
      @services[0, 5].each do |service|
        expect(service).to receive(:up).once.ordered
      end
      expect(@services[5]).to receive(:up).once.ordered
      expect(@services[5]).to receive(:down).once.ordered
      @services[0, 5].reverse.each do |service|
        expect(service).to receive(:down).once.ordered
      end

      @dispatch.process(@services)
    end
  end

  context "with a list of successful services" do
    setup do
      @services = 10.times.map { SuccessfulService.new }
    end

    it_behaves_like "a list of rollable back services"

    it "executes :up in all the list in order" do
      @services.each do |s|
        expect(s).to receive(:up).once.ordered
      end
      @dispatch.process(@services)      
    end

    it "does not call :down in any of them" do
      

      expect(@services.first).to receive(:up)
      @services.each do |s|
        expect(s).not_to receive(:down)
      end  
      @dispatch.process(@services)          
    end

    it "returns true for the successful list" do
      expect(@dispatch.process(@services)).to eq(true)
    end
  end

  context "with a list of wrong services" do
    setup do
      @services = 10.times.map { FailService.new }
    end

    it_behaves_like "a list of rollable back services"

    it "tries to execute :up just the first element" do
      expect(@services.first).to receive(:up).once
      @services[1, @services.length - 2].each do |service|
        expect(service).not_to receive(:up)
         expect(service).not_to receive(:down)
      end

      @dispatch.process(@services)
    end

    it "executes :down just after the failed :up" do
      expect(@services.first).to receive(:up).once.ordered
      expect(@services.first).to receive(:down).once.ordered

      @services[1, @services.length - 2].each do |service|
        expect(service).not_to receive(:up)
      end
      @dispatch.process(@services)      
    end

    it "returns false for the faulty list" do
      expect(@dispatch.process(@services)).to eq(false)
    end
  end

  context "with a mix of faulty and successful services" do

    context 'with 5 good, 5 bad' do
      setup do
        @services = [5.times.map { SuccessfulService.new }, 5.times.map { FailService.new}].flatten
      end
      it_behaves_like "a list of rollable back services"
    end


    context 'with 5 bad, 5 good' do
      setup do
        @services = [5.times.map { FailService.new }, 5.times.map { SuccessfulService.new}].flatten
      end
      it_behaves_like "a list of rollable back services"
    end

    context 'with 10 alternated good and bad' do
      setup do
        @services = 5.times.map { SuccessfulService.new }.zip(5.times.map { FailService.new}).flatten
      end
      it_behaves_like "a list of rollable back services"
    end

  end


end
