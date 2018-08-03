require 'taxonomy_client'

Rails.application.config.after_initialize do
  TaxonomyClient::Model.site = "https://www.ebi.ac.uk"

  TaxonomyClient::Model.connection do |connection|
    # Remove deprecation warning by sending empty hash
    # http://www.rubydoc.info/github/lostisland/faraday/Faraday/Connection

    # Enable HTTP cache
    connection.use Faraday::HttpCache, store: Rails.cache
  end

  # Only use Sanger proxy when on system's infrastructure
  # TODO: remove if production is on OpenStack
  if Rails.env.production?
    TaxonomyClient::Taxonomy.connection.faraday.proxy = Rails.configuration.aker_deployment_default_proxy
  end
end
