require 'bunny'
require 'event_publisher'
require 'ostruct'

if Rails.configuration.enable_events_sending
  EventService = EventPublisher.new(event_conn: Rails.configuration.events_queue_connection,
    queue_name: Rails.configuration.events_queue_name)
  # The connection should be created in the initializer, so we'll keep the following line
  # here (http://rubybunny.info/articles/connecting.html for more info)
  EventService.create_connection
else
  EventService = Class.new do
    def self.publish(obj)
    end
    def self.create_connection
    end
  end
end
