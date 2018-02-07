# frozen_string_literal: true

require 'rails_helper'
require 'set'

RSpec.describe 'EventPublisher' do
  let(:bunny) { double('Bunny') }

  setup do
    stub_const('Bunny', bunny)
    allow_any_instance_of(EventPublisher).to receive(:add_close_connection_handler).and_return true

    @params = { broker_host: 'broker_host',
                broker_port: 'broker_port',
                broker_username: 'broker_username',
                broker_password: 'broker_password',
                exchange_name: 'exchange_name',
                warehouse_queue_name: 'warehouse_queue_name',
                notification_queue_name: 'notification_queue_name' }
  end

  def mock_connection(params)
    @connection = double('connection')
    @channel = double('channel')
    @exchange = double('exchange')
    @queue = double('queue')

    allow(bunny).to receive(:new).with(
      host: params[:broker_host],
      port: params[:broker_port],
      vhost: params[:broker_vhost],
      user: params[:broker_username],
      pass: params[:broker_password],
      threaded: false
    ).and_return(@connection)
    allow(@connection).to receive(:start)
    allow(@connection).to receive(:create_channel).and_return(@channel)
    allow(@channel).to receive(:queue).and_return(@queue)
    allow(@channel).to receive(:default_exchange).and_return(@exchange)
    allow(@channel).to receive(:confirm_select)
    allow(@channel).to receive(:wait_for_confirms)
    allow(@channel).to receive(:topic).and_return(@exchange)
    allow(@channel).to receive(:fanout).and_return(@exchange)
    allow(@exchange).to receive(:name).and_return('exchange name')

    allow(@queue).to receive(:bind)
  end

  describe '#creating connections' do
    it 'initialize methods are called' do
      allow_any_instance_of(EventPublisher)
        .to receive(:start_connection).and_return true
      allow_any_instance_of(EventPublisher)
        .to receive(:create_exchanges_and_queues).and_return true

      ep = EventPublisher.new(@params)
      ep.create_connection

      expect(ep).to have_received(:start_connection)
      expect(ep).to have_received(:create_exchanges_and_queues)
      expect(ep).to have_received(:add_close_connection_handler)
    end

    it 'does not create a connection if a connection already exists' do
      mock_connection(@params)
      ep = EventPublisher.new(@params)

      allow(ep).to receive(:connected?).and_return(true)
      allow(ep).to receive(:start_connection)
      allow(ep).to receive(:create_exchanges_and_queues)
      allow(ep).to receive(:add_close_connection_handler)
      ep.create_connection

      expect(ep).not_to have_received(:start_connection)
      expect(ep).not_to have_received(:create_exchanges_and_queues)
      expect(ep).not_to have_received(:add_close_connection_handler)
    end
  end

  describe '#start_connection' do
    it 'starts a new connection' do
      mock_connection(@params)

      expect(@connection).to receive(:start)
      expect(@connection).to receive(:create_channel)
      expect(@channel).to receive(:queue)

      ep = EventPublisher.new(@params)
      ep.create_connection
    end
  end

  describe '#publishing messages' do
    setup do
      mock_connection(@params)
      @event_message = instance_double('EventMessage')
      allow(@event_message).to receive(:generate_json).and_return('message')

      allow(@queue).to receive(:name).and_return(@params[:queue_name])
    end

    context 'unconfirmed set is empty' do
      before(:each) do
        @unconfirmed_sets = Set.new([])
      end

      it 'publishes a new message to the queue' do
        allow(@channel).to receive(:unconfirmed_set).and_return(@unconfirmed_sets)

        ep = EventPublisher.new(@params)
        expect(@exchange).to receive(:publish).with('message')
        ep.publish(@event_message)
      end
    end

    context 'unconfirmed set is not empty' do
      before(:each) do
        @unconfirmed_sets = Set.new([1])
      end

      it 'raises exception if unconfirmed set is not empty' do
        allow(@channel).to receive(:unconfirmed_set).and_return(@unconfirmed_sets)

        ep = EventPublisher.new(@params)
        expect(@exchange).to receive(:publish).with('message')
        expect { ep.publish(@event_message) }.to raise_error(/unconfirmed/)
      end
    end
  end
end
