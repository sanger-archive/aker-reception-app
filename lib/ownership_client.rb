require 'faraday'

module OwnershipClient

  def post(params)
    conn = Faraday.new(:url => Rails.application.config.ownership_url)
    conn.proxy Rails.application.config.ownership_url_default_proxy
    conn.post '/ownerships', { :ownership => params }
  end

  def get(id)
    conn = Faraday.new(:url => Rails.application.config.ownership_url)
    conn.proxy Rails.application.config.ownership_url_default_proxy
    conn.get '/ownerships/'+id
  end

  def delete
  	raise 'Not implemented'
  end
end