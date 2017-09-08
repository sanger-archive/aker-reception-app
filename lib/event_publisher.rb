require 'event_message'

class EventPublisher

  attr_accessor :connection
  attr_reader :channel, :exchange
  attr_reader :dlx, :dlx_queue

  def initialize(config={})
    @event_conn = config[:event_conn]
    @queue_name = config[:queue_name]
  end

  def create_connection
    if !connected?
      connect!
    end
  end

  def connect!
    set_config
    add_close_connection_handler
  end

  def connected?
    !@connection.nil?
  end

  def publish(message)
    create_connection if !connected?
    puts "@queue: #{@queue}"
    puts "@exchange: #{@exchange}"
    puts "message.generate_json: #{message.generate_json}"
    @exchange.publish(message.generate_json, routing_key: @queue.name)
    @channel.wait_for_confirms
    if @channel.unconfirmed_set.count > 0
      raise "There is an unconfirmed set"
    end
  end

  def close
    @connection.close
  end

  private

  def add_close_connection_handler
    at_exit {
      puts 'RabbitMQ connection close'
      close
      exit 0
    }
  end

  def set_config
    # threaded is set to false because otherwise the connection creation is not working
    @connection = Bunny.new(@event_conn, threaded: false)
    @connection.start

    dl_queue_name = @queue_name+'.deadletters'

    @channel   = @connection.create_channel
    @exchange    = @channel.fanout(@queue_name)

    # Creates the dead letter exchange aker.events.deadletters
    @dlx  = @channel.fanout(dl_queue_name)

    # Creates the queue aker.events with dead letter exchange defined aker.events.deadletters
    # auto_delete false ensures that we dont destroy the queue when there are no messages and no
    # consumers are running
    @queue    = @channel.queue(@queue_name, :auto_delete => false,
      :arguments => {
      "x-dead-letter-exchange" => @dlx.name
    }).bind(@exchange)

    # dead letter queue
    @dlx_queue  = @channel.queue(dl_queue_name).bind(@dlx)

    # To be able to wait_for_confirms in publish()
    @channel.confirm_select
  end

end
