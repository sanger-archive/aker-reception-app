require 'jwt_serializer'

Rails.application.config.after_initialize do
  SetClient::Base.site = Rails.application.config.set_url

  SetClient::Base.connection do |connection|
    connection.use JWTSerializer
  end

  if Rails.env.production? || Rails.env.staging?
    SetClient::Base.connection do |connection|
      connection.use ZipkinTracer::FaradayHandler
    end
  end
end
