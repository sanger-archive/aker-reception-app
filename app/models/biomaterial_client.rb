require 'faraday'

module BiomaterialClient
  def site
	  RestClient::Resource.new(Rails.configuration.materials_service_url)
  end

  def process_response(response)
    if response
      JSON.parse(response.body)
    else
      nil
    end    
  end

  def post(data)
	  process_response(self.site["materials"].post(data, :content_type => 'text/json'))
  end

  def put(data)
    data_to_send = data.reject{|k,v| k.to_sym == :uuid}
	  process_response(self.site["materials"][data[:uuid]].put(data_to_send, :content_type => 'text/json'))
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
