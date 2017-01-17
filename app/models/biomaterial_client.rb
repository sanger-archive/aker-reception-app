require 'rest-client'

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
    begin
    	return nil if uuid.nil?
    	return process_response(self.site["materials"][uuid].get(:content_type => 'text/json'))
    rescue RestClient::ExceptionWithResponse => e
      return nil
    end
  end
end