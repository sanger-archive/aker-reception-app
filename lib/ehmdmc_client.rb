require 'faraday'

module EHMDMCClient

  def self.validate?(hmdmc)
    r = connection.get('?hmdmc=' + sanitise(hmdmc))
    unless r.status==200
      # Something went wrong
      Rails.logger.error "Attempting to validate HMDMC #{hmdmc} returned status code #{r.status}"
      return false
    end
    begin
      data = JSON.parse(r.body)
    rescue JSON::ParserError
      Rails.logger.error "Attempting to validate HMDMC #{hmdmc} produced invalid JSON: #{r.body}"
      return false
    end
    return true if data['valid']
    # The HMDMC was refused
    Rails.logger.info "HMDMC rejected: #{hmdmc}, error code: #{data['errorcode']}"
    # Error codes, from Stephen Rice:
    # 0: no error (valid)
    # 1: system error
    # 2: syntax error, i.e. malformed HMDMC number
    # 3: number has correct syntax but does not exist in system
    # 4: number does exist in system but is not approved
    # 5: valid but failed to find any product classes
    return false
  end

  def self.sanitise(hmdmc)
    hmdmc.sub('/','_')
  end

  def self.connection
    Faraday.new(url: Rails.application.config.ehmdmc_url)
  end
end
