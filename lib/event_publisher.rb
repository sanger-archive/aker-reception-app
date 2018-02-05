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
    create_exchanges_and_queues
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

  def create_exchanges_and_queues
    dl_exchange_name = @exchange_name + '.deadletters'

    @channel = @connection.create_channel

    # Create a fanout exchange which will send messages to all queues bound to the exchange and
    #   make the exchange durable: Durable exchanges survive broker restart, transient exchanges
    #   do not (http://rubybunny.info/articles/durability.html)
    @exchange = @channel.fanout(@exchange_name, durable: true)

    # Creates the dead letter exchange aker.events.deadletters (https://www.rabbitmq.com/dlx.html)
    @dlx = @channel.fanout(dl_exchange_name, durable: true)

    # Creates the queues with dead letter exchange defined as aker.events.deadletters. We also
    #   set `auto_delete` to false which ensures that we dont destroy the queue when there are
    #   no messages and no consumers are running. Finally, we also bind the queue to the exchange.
    # warehouse_queue
    @channel.queue(@warehouse_queue_name,
                   auto_delete: false,
                   durable: true,
                   arguments: {
                     "x-dead-letter-exchange": @dlx.name
                   }).bind(@exchange)
    # notifications_queue
    @channel.queue(@notification_queue_name,
                   auto_delete: false,
                   durable: true,
                   arguments: {
                     "x-dead-letter-exchange": @dlx.name
                   }).bind(@exchange)
    # Dead letter queues
    dl_queue_name = @exchange_name + '.deadletters'
    @channel.queue(dl_queue_name, durable: true).bind(@dlx, durable: true)

    # To be able to wait_for_confirms in publish()
    @channel.confirm_select
  end
end
