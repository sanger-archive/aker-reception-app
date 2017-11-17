require 'taxonomy_client'

Rails.application.config.after_initialize do
  TaxonomyClient::Model.site = "https://www.ebi.ac.uk"

  TaxonomyClient::Model.connection do |connection|
    ENV['HTTP_PROXY'] = nil
    ENV['http_proxy'] = nil
    ENV['https_proxy'] = nil

    # Remove deprecation warning by sending empty hash
    # http://www.rubydoc.info/github/lostisland/faraday/Faraday/Connection
    connection.faraday.proxy {}

    # Enable HTTP cache
    connection.use Faraday::HttpCache, store: Rails.cache

    if Rails.env.production? || Rails.env.staging?
      connection.use ZipkinTracer::FaradayHandler, "Taxonomy Service"
    end
  end
end
