require 'taxonomy_client'

Rails.application.config.after_initialize do
  TaxonomyClient::Model.site = "https://www.ebi.ac.uk"

  TaxonomyClient::Model.connection do |connection|
    # Remove deprecation warning by sending empty hash
    # http://www.rubydoc.info/github/lostisland/faraday/Faraday/Connection

    # Enable HTTP cache
    connection.use Faraday::HttpCache, store: Rails.cache
  end

  # Use Sanger proxy everywhere except local 'development' and new OpenStack 'wip' environment
  if !(Rails.env.development? || Rails.env.wip? || Rails.env.uat2?)
    TaxonomyClient::Taxonomy.connection.faraday.proxy = Rails.configuration.aker_deployment_default_proxy
  end
end
