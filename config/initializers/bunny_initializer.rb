# frozen_string_literal: true

require 'bunny'
require 'event_publisher'
require 'ostruct'

if Rails.configuration.events[:enabled]
  EventService = EventPublisher.new(
    broker_host: Rails.configuration.events[:broker_host],
    broker_port: Rails.configuration.events[:broker_port],
    broker_username: Rails.configuration.events[:broker_username],
    broker_password: Rails.configuration.events[:broker_password],
    exchange_name: Rails.configuration.events[:exchange_name],
    warehouse_queue_name: Rails.configuration.events[:warehouse_queue_name],
    notification_queue_name: Rails.configuration.events[:notification_queue_name]
  )
  # The connection should be created in the initializer, so we'll keep the following line
  # here (http://rubybunny.info/articles/connecting.html for more info)
  EventService.create_connection
else
  EventService = Class.new do
    def self.publish(obj); end

    def self.create_connection; end
  end
end
