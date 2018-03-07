# frozen_string_literal: true

require 'event_publisher'

if Rails.configuration.events[:enabled]
  EventService = EventPublisher.new
  # The connection should be created in the initializer, so we'll keep the following line
  # here (http://rubybunny.info/articles/connecting.html for more info)
  EventService.create_connection
else
  EventService = Class.new do
    def self.publish(obj); end

    def self.create_connection; end
  end
end
