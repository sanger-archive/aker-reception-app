require 'rails_helper'

require 'set'

RSpec.describe 'EventPublisher' do

  let(:bunny) { double('Bunny') }

  setup do
    stub_const("Bunny", bunny)
    allow_any_instance_of(EventPublisher).to receive(:add_close_connection_handler).and_return true
  end

  def mock_connection(params)
    @connection = double('connection')
    @channel = double('channel')
    @exchange = double('exchange')
    @queue = double('queue')

    allow(@queue).to receive(:bind).with(@exchange).and_return(@queue)
    allow(@queue).to receive(:name).and_return("queue name")
    allow(bunny).to receive(:new).with(params[:event_conn], threaded: false).and_return(@connection)
    allow(@connection).to receive(:start)
    allow(@connection).to receive(:create_channel).and_return(@channel)
    allow(@channel).to receive(:queue).and_return(@queue)
    allow(@channel).to receive(:default_exchange).and_return(@exchange)
    allow(@channel).to receive(:confirm_select)
    allow(@channel).to receive(:wait_for_confirms)
    allow(@channel).to receive(:fanout).and_return(@exchange)
    allow(@exchange).to receive(:name).and_return('exchange name')

  end

  describe '#create_connection' do

    it 'initialize methods are called' do

      allow_any_instance_of(EventPublisher).to receive(:set_config).and_return true

      params = { event_conn: 'event conn', queue_name: 'queue name' }
      ep = EventPublisher.new(params)
      ep.create_connection

      expect(ep).to have_received(:set_config)
      expect(ep).to have_received(:add_close_connection_handler)
    end
    it 'does not create connection if connection is already created' do
      params = { event_conn: 'event conn', queue_name: 'queue name' }
      mock_connection(params)
      ep = EventPublisher.new(params)

      allow(ep).to receive(:connected?).and_return(true)
      allow(ep).to receive(:set_config)
      allow(ep).to receive(:add_close_connection_handler)
      ep.create_connection

      expect(ep).not_to have_received(:set_config)
      expect(ep).not_to have_received(:add_close_connection_handler)
    end
  end

  describe '#set_config' do
    it 'starts a new connection' do

      params = { event_conn: 'event_conn', queue_name: 'queue_name' }
      mock_connection(params)

      expect(@connection).to receive(:start)
      expect(@connection).to receive(:create_channel)
      expect(@channel).to receive(:queue)

      ep = EventPublisher.new(params)
      ep.create_connection
    end
  end

  context '#publish' do
    setup do
      Bunny ||= double('Bunny')
      @params = { event_conn: 'event_conn', queue_name: 'queue_name' }
      mock_connection(@params)
      @event_message = instance_double("EventMessage")
      allow(@event_message).to receive(:generate_json).and_return("message")

      allow(@queue).to receive(:name).and_return(@params[:queue_name])
    end

    it 'publishes a new message to the queue' do
      unconfirmed_sets = Set.new([])
      allow(@channel).to receive(:unconfirmed_set).and_return(unconfirmed_sets)

      ep = EventPublisher.new(@params)
      expect(@exchange).to receive(:publish).with('message', routing_key: @params[:queue_name])
      ep.publish(@event_message)
    end

    it 'raises exception if unconfirmed set is not empty' do
      unconfirmed_sets = Set.new([1])
      allow(@channel).to receive(:unconfirmed_set).and_return(unconfirmed_sets)

      ep = EventPublisher.new(@params)
      expect(@exchange).to receive(:publish).with('message', routing_key: @params[:queue_name])
      expect{ep.publish(@event_message)}.to raise_error(/unconfirmed/)
    end
  end
end
