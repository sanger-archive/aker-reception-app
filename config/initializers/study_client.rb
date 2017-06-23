require 'jwt_serializer'

Rails.application.config.after_initialize do
  StudyClient::Base.site = Rails.application.config.study_url

  StudyClient::Base.connection do |connection|
    ENV['HTTP_PROXY'] = nil
    ENV['http_proxy'] = nil
    ENV['https_proxy'] = nil
    connection.faraday.proxy ''
    connection.use JWTSerializer
  end

  if Rails.env.production? || Rails.env.staging?
    StudyClient::Base.connection do |connection|
      connection.use ZipkinTracer::FaradayHandler
    end
  end
end
