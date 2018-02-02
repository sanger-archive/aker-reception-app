# frozen_string_literal: true

require 'event_message'

# The EventPublisher configures the connection to the broker and creates the exchange and
#   queues.
class EventPublisher
  attr_accessor :connection
  attr_reader :channel, :exchange, :dlx, :dlx_queue

  def initialize(config = {})
    @broker_host = config[:broker_host]
    @broker_port = config[:broker_port]
    @broker_vhost = config[:broker_vhost]
    @broker_username = config[:broker_username]
    @broker_password = config[:broker_password]
    @exchange_name = config[:exchange_name]
    @warehouse_queue_name = config[:warehouse_queue_name]
    @notification_queue_name = config[:notification_queue_name]
  end

  def create_connection
    !connected? && connect!
  end

  def connect!
    start_connection
    add_close_connection_handler
  end

  def connected?
    !@connection.nil?
  end

  def publish(message)
    create_connection unless connected?
    @exchange.publish(message.generate_json)
    @channel.wait_for_confirms
    raise 'There is an unconfirmed set.' if @channel.unconfirmed_set.count.positive?
  end

  def close
    @connection.close
  end

  private

  def add_close_connection_handler
    at_exit do
      puts 'RabbitMQ connection close.'
      close
      exit 0
    end
  end

  def start_connection
    # Threaded is set to false because otherwise the connection creation is not working
    @connection = Bunny.new(
      host: @broker_host,
      port: @broker_port,
      vhost: @broker_vhost,
      user: @broker_username,
      pass: @broker_password,
      threaded: false
    )
    @connection.start
  end
end
