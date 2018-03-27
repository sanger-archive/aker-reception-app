# frozen_string_literal: true

require 'bunny'
require 'event_message'
require 'ostruct'

# The EventPublisher configures the connection to the broker
class EventPublisher
  attr_accessor :connection
  attr_reader :channel, :exchange, :dlx, :dlx_queue

  def initialize
    @events_config = OpenStruct.new(Rails.configuration.events)
  end

  def create_connection
    !connected? && connect!
  end

  def connect!
    start_connection
    exchange_handler
    add_close_connection_handler
  end

  def connected?
    !@connection.nil?
  end

  def publish(message)
    create_connection unless connected?
    @exchange.publish(message.generate_json, routing_key: EventMessage::ROUTING_KEY)
    @channel.wait_for_confirms
    raise 'There is an unconfirmed set.' if @channel.unconfirmed_set.count.positive?
  end

  def close
    @connection.close
  end

  private

  def add_close_connection_handler
    at_exit do
      Rails.logger.info 'RabbitMQ connection closed.'
      close
    end
  end

  def start_connection
    @connection = Bunny.new host: @events_config.broker_host,
                            port: @events_config.broker_port,
                            username: @events_config.broker_username,
                            password: @events_config.broker_password,
                            vhost: @events_config.vhost
    @connection.start
  end

  def exchange_handler
    @channel = @connection.create_channel

    # Get a handle to the topic exchange which will send messages to queues bound to the exchange
    #   using specific routing keys
    @exchange = @channel.topic(@events_config.exchange, passive: true)

    # To be able to wait_for_confirms in publish()
    @channel.confirm_select
  end
end
