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
                vhost: 'vhost',
                exchange_name: 'exchange_name' }
    allow(Rails.application.config).to receive(:events).and_return(@params)
  end

  def mock_connection
    @connection = double('connection')
    @channel = double('channel')
    @exchange = double('exchange')

    allow(bunny).to receive(:new).and_return(@connection)
    allow(@connection).to receive(:start)
    allow(@connection).to receive(:create_channel).and_return(@channel)
    allow(@channel).to receive(:default_exchange).and_return(@exchange)
    allow(@channel).to receive(:confirm_select)
    allow(@channel).to receive(:wait_for_confirms)
    allow(@channel).to receive(:topic).and_return(@exchange)
    allow(@exchange).to receive(:name).and_return('exchange name')
  end

  describe '#creating connections' do
    it 'initialize methods are called' do
      allow_any_instance_of(EventPublisher)
        .to receive(:start_connection).and_return true
      allow_any_instance_of(EventPublisher)
        .to receive(:exchange_handler).and_return true

      ep = EventPublisher.new
      ep.create_connection

      expect(ep).to have_received(:start_connection)
      expect(ep).to have_received(:exchange_handler)
      expect(ep).to have_received(:add_close_connection_handler)
    end

    it 'does not create a connection if a connection already exists' do
      mock_connection
      ep = EventPublisher.new

      allow(ep).to receive(:connected?).and_return(true)
      allow(ep).to receive(:start_connection)
      allow(ep).to receive(:exchange_handler)
      allow(ep).to receive(:add_close_connection_handler)
      ep.create_connection

      expect(ep).not_to have_received(:start_connection)
      expect(ep).not_to have_received(:exchange_handler)
      expect(ep).not_to have_received(:add_close_connection_handler)
    end
  end

  describe '#start_connection' do
    it 'starts a new connection' do
      mock_connection

      expect(@connection).to receive(:start)
      expect(@connection).to receive(:create_channel)
      expect(@channel).to receive(:topic)

      ep = EventPublisher.new
      ep.create_connection
    end
  end

  describe '#publishing messages' do
    setup do
      mock_connection
      @event_message = instance_double('EventMessage')
      allow(@event_message).to receive(:generate_json).and_return('message')

      # allow(@queue).to receive(:name).and_return(@params[:queue_name])
    end

    context 'unconfirmed set is empty' do
      before(:each) do
        @unconfirmed_sets = Set.new([])
      end

      it 'publishes a new message to the queue' do
        allow(@channel).to receive(:unconfirmed_set).and_return(@unconfirmed_sets)

        ep = EventPublisher.new
        expect(@exchange).to receive(:publish).with('message',
                                                    routing_key: 'aker.events.submission')
        ep.publish(@event_message)
      end
    end

    context 'unconfirmed set is not empty' do
      before(:each) do
        @unconfirmed_sets = Set.new([1])
      end

      it 'raises exception if unconfirmed set is not empty' do
        allow(@channel).to receive(:unconfirmed_set).and_return(@unconfirmed_sets)

        ep = EventPublisher.new
        expect(@exchange).to receive(:publish).with('message',
                                                    routing_key: 'aker.events.submission')
        expect { ep.publish(@event_message) }.to raise_error(/unconfirmed/)
      end
    end
  end
end
