require 'rails_helper'

RSpec.describe :dispatch_service do
  let(:successful_service) { double("Service", up: true, down: true) }
  let(:fail_service) { double("Service", up: false, down: true) }
  let(:faulty_rollable_back) { double("Service", up: false, down: true) }
  let(:faulty_not_rollable_back) { double("Service", up: false, down: false) }
  
  setup do
    @dispatch = DispatchService.new
  end

  shared_examples "a list of rollable back services" do
    it "tries to execute the successful services until the faulty one and then rolls back in reverse order" do
      failure = false
      list = []
      services.each do |service|
        actual_return = service.up
        unless failure
          expect(service).to receive(:up).and_return(actual_return).once.ordered
          list.push(service) if actual_return || failure
        end
        failure ||= (!actual_return)
      end
      if failure
        list.reverse.each do |service|
          expect(service).to receive(:down).and_return(service.down).once.ordered
        end
      end

      @dispatch.process(services)
    end
  end

  context "with a list of successful services" do
    let(:services) { 10.times.map { successful_service.clone } }

    it_behaves_like "a list of rollable back services"

    it "executes :up in all the list in order" do
      services.each do |s|
        expect(s).to receive(:up).and_return(s.up).once.ordered
      end
      @dispatch.process(services)      
    end

    it "does not call :down in any of them" do
      expect(services.first).to receive(:up).and_return(services.first.up).once.ordered
      services.each do |s|
        expect(s).not_to receive(:down)
      end  
      @dispatch.process(services)          
    end

    it "returns true for the successful list" do
      expect(@dispatch.process(services)).to eq(true)
    end
  end

  context "with a list of wrong services" do
    let(:services) { 10.times.map { fail_service.clone } }

    it_behaves_like "a list of rollable back services"

    it "tries to execute :up just the first element" do
      expect(services.first).to receive(:up).and_return(services.first.up).once.ordered
      services[1, services.length - 2].each do |service|
        expect(service).not_to receive(:up)
         expect(service).not_to receive(:down)
      end

      @dispatch.process(services)
    end

    it "returns false for the faulty list" do
      expect(@dispatch.process(services)).to eq(false)
    end
  end

  context "with a mix of faulty and successful services" do

    context 'with 5 good, 5 bad' do
      let(:services) { [5.times.map { successful_service.clone }, 5.times.map { fail_service.clone }].flatten }

      it_behaves_like "a list of rollable back services"
    end


    context 'with 5 bad, 5 good' do
      let(:services) { [5.times.map { fail_service.clone }, 5.times.map { successful_service.clone }].flatten }

      it_behaves_like "a list of rollable back services"
    end

    context 'with 10 alternated good and bad' do
      let(:services) { 5.times.map { successful_service.clone }.zip(5.times.map { fail_service.clone }).flatten }

      it_behaves_like "a list of rollable back services"
    end

  end


end
