require 'jwt_serializer'

Rails.application.config.after_initialize do
  StudyClient::Base.site = Rails.application.config.study_url

  StudyClient::Base.connection do |connection|
    connection.use JWTSerializer
  end

  if Rails.env.production? || Rails.env.staging?
    StudyClient::Base.connection do |connection|
      connection.use ZipkinTracer::FaradayHandler
    end
  end
end
