require 'faraday'

module BiomaterialClient

  def post(data)
    conn = get_connection
    JSON.parse(conn.post('/materials/', data.to_json).body)
  end

  def put(data)
    uuid = data[:uuid]
    data_to_send = data.reject{|k,v| k.to_sym == :uuid}
    conn = get_connection
    JSON.parse(conn.post('/materials/'+uuid, data_to_send.to_json).body)
  end

  def get(uuid)
      return nil if uuid.nil?
      conn = get_connection
      conn.headers = {'Accept' => 'application/vnd.api+json'} 
      JSON.parse(get_connection.get('/materials/'+uuid).body)
  end

  private 
  
  def get_connection
      conn = Faraday.new(:url => Rails.application.config.materials_service_url)
      conn.proxy Rails.application.config.materials_service_url
      conn.headers = {'Content-Type' => 'application/vnd.api+json'} 
      conn
  end

end