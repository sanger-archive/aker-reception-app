
Rails.application.config.after_initialize do
  StudyClient::Base.site = Rails.application.config.study_url

  if Rails.env.test? || Rails.env.staging?
    StudyClient::Base.connection do |connection|
      connection.use ZipkinTracer::FaradayHandler
    end
  end
end
