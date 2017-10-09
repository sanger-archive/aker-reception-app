Rails.application.config.after_initialize do
  StudyClient::Base.site = Rails.application.config.study_url

  StudyClient::Base.connection do |connection|
    ENV['HTTP_PROXY'] = nil
    ENV['http_proxy'] = nil
    ENV['https_proxy'] = nil

    # Remove deprecation warning by sending empty hash
    # http://www.rubydoc.info/github/lostisland/faraday/Faraday/Connection
    connection.faraday.proxy {}
    connection.use JWTSerializer

    if Rails.env.production? || Rails.env.staging?
      connection.use ZipkinTracer::FaradayHandler, "Study service"
    end
  end
end
