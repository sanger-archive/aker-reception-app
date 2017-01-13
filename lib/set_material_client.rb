require 'faraday'

module SetMaterialClient

	def self.post(params)
		conn = get_connection
		JSON.parse(conn.post('/api/v1/sets', params.to_json).body)
	end

	def self.get(uuid)
		conn = get_connection
		conn.headers = {'Accept' => 'application/vnd.api+json'} 
    	JSON.parse(get_connection.get('/api/v1/sets/'+uuid).body)
	end

	private 

	def self.get_connection
		conn = Faraday.new(:url => Rails.application.config.set_url)
	    conn.proxy Rails.application.config.set_url_default_proxy
	    conn.headers = {'Content-Type' => 'application/vnd.api+json'} 
	    conn
	end

end
