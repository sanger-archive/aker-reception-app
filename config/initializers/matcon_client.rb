Rails.application.config.after_initialize do
  MatconClient::Model.site = Rails.application.config.material_url

  MatconClient::Model.connection do |connection|
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
