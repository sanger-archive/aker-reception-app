Rails.application.config.after_initialize do
  StampClient::Base.site = Rails.application.config.stamp_url

  StampClient::Base.connection do |connection|
    ENV['HTTP_PROXY'] = nil
    ENV['http_proxy'] = nil
    ENV['https_proxy'] = nil

    # Remove deprecation warning by sending empty hash
    # http://www.rubydoc.info/github/lostisland/faraday/Faraday/Connection
    connection.faraday.proxy {}
    connection.use JWTSerializer
    connection.use RequestIdMiddleware
  end
end
