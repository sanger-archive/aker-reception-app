require 'faraday'

module OwnershipClient

  def self.post(params)
    get_connection.post('/ownerships', { :ownership => params }).body
  end

  def self.post_batch(params)
    get_connection.post('/ownerships/batch', { :ownership => params }).body
  end

  def self.get(uuid)
    get_connection.get('/ownerships/'+uuid).body
  end

  def delete
  	raise 'Not implemented'
  end

  def self.get_connection
    conn = Faraday.new(:url => Rails.application.config.ownership_url) do |faraday|
      faraday.use ZipkinTracer::FaradayHandler, 'ownership service'
    end

    conn.proxy Rails.application.config.ownership_url_default_proxy
    conn
  end
end