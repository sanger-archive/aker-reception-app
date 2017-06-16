require 'faraday'

module EHMDMCClient

  def self.validate?(hmdmc)
    r = connection.get('?hmdmc=' + sanitise(hmdmc))
    return true if r.status==200
    Rails.logger.info "Attempting to validate HMDMC #{hmdmc} returned status code #{r.status}"
    false
  end

  def self.sanitise(hmdmc)
    hmdmc.sub('/','_')
  end

  def self.connection
    Faraday.new(:url => Rails.application.config.ehmdmc_url)
  end
end
