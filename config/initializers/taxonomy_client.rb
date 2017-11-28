require 'taxonomy_client'

Rails.application.config.after_initialize do
  TaxonomyClient::Model.site = "https://www.ebi.ac.uk"

  TaxonomyClient::Model.connection do |connection|
    # Remove deprecation warning by sending empty hash
    # http://www.rubydoc.info/github/lostisland/faraday/Faraday/Connection
    

    # Enable HTTP cache
    connection.use Faraday::HttpCache, store: Rails.cache

    if Rails.env.production? || Rails.env.staging?
      connection.use ZipkinTracer::FaradayHandler, "Taxonomy Service"
    end
  end
  TaxonomyClient::Taxonomy.connection.faraday.proxy=Rails.configuration.aker_deployment_default_proxy
end
