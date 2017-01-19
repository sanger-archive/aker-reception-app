require 'faraday'
module BiomaterialClient

  def post(data)
    conn = get_connection

    response = conn.post do |req|
      req.url '/materials'
      req.headers['Content-Type'] = 'application/json'
      req.body = data.to_json
    end
    JSON.parse(response.body)
  end

  def put(data)
    uuid = data[:uuid]
    data_to_send = data.reject{|k,v| k.to_sym == :uuid}
    conn = get_connection

    response = conn.post do |req|
      req.url '/materials/'+uuid
      req.headers['Content-Type'] = 'application/json'
      req.body = data_to_send.to_json
    end
    JSON.parse(response.body)
  end

  def get(uuid)
  	return nil if uuid.nil?
    conn = get_connection

    response = conn.get do |req|
      req.url '/materials/'+uuid
      req.headers['Content-Type'] = 'application/json'
    end   
    JSON.parse(response.body)
  end

  private

  def get_connection
    conn = Faraday.new(:url => Rails.application.config.material_url) do |faraday|
      faraday.request  :url_encoded
      faraday.response :logger
      faraday.adapter  Faraday.default_adapter 
      faraday.proxy Rails.application.config.material_url
    end
    conn
  end

end
