Rails.application.config.after_initialize do

  StampClient::Base.site = Rails.application.config.stamp_url

  StampClient::Base.connection do |connection|
    ENV['HTTP_PROXY'] = nil
    ENV['http_proxy'] = nil
    ENV['https_proxy'] = nil
    connection.faraday.proxy ''
    connection.use JWTSerializer
    if Rails.env.production? || Rails.env.staging?
      connection.use ZipkinTracer::FaradayHandler, 'Stamp service'
    end
  end
end
