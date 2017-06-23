Rails.application.config.after_initialize do
  MatconClient::Model.site = Rails.application.config.material_url

  MatconClient::Model.connection do |connection|
    ENV['HTTP_PROXY'] = nil
    ENV['http_proxy'] = nil
    ENV['https_proxy'] = nil
    connection.faraday.proxy ''
    connection.use JWTSerializer
  end

  if Rails.env.production? || Rails.env.staging?
    MatconClient::Model.connection do |connection|
      connection.use ZipkinTracer::FaradayHandler
    end
  end
end
