Rails.application.config.after_initialize do
  MatconClient::Model.site = Rails.application.config.material_url

  if Rails.env.production? || Rails.env.staging?
    MatconClient::Model.connection do |connection|
      connection.use ZipkinTracer::FaradayHandler
    end
  end
end
