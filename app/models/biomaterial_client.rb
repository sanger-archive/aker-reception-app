require 'faraday'
# require 'zipkin-tracer'

module BiomaterialClient

  def post(data)
    conn = get_connection
    JSON.parse(conn.post('/materials', data.to_json).body)
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
    JSON.parse(conn.get('/materials/'+uuid).body)
  end

  private

  def get_connection
    conn = Faraday.new(:url => Rails.application.config.material_url) do |faraday|
      # faraday.use ZipkinTracer::FaradayHandler, 'eve'
      faraday.proxy Rails.application.config.material_url
      faraday.request  :url_encoded
      faraday.response :logger
      faraday.adapter  Faraday.default_adapter 
    end
    conn.headers = {'Content-Type' => 'application/json'} 
    conn
  end

end
