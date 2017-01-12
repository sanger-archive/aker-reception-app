require 'faraday'
require 'json'

module OwnershipClient

  def self.post(params)
    JSON.parse(get_connection.post('/ownerships', { :ownership => params }).body)
  end

  def self.get(uuid)
    JSON.parse(get_connection.get('/ownerships/'+uuid).body)
  end

  def delete
  	raise 'Not implemented'
  end

  def self.get_connection
    conn = Faraday.new(:url => Rails.application.config.ownership_url)
    conn.proxy Rails.application.config.ownership_url_default_proxy
    conn
  end
end