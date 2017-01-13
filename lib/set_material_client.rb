require 'faraday'

module SetMaterialClient

	def self.post(params)
		JSON.parse(get_connection.post('/api/v1/sets', { :set => params }).body)

		# conn = Faraday.new(:url => get_set_url)
		# conn.proxy Rails.application.config.set_url_default_proxy
		# conn.headers = {'Content-Type' => 'application/vnd.api+json'} 
		# conn = get_connection
		# conn.post '/api/v1/sets', { :set => params }
	end

	def self.get
		conn = Faraday.new(:url => get_set_url)
		conn.proxy Rails.application.config.set_url_default_proxy
		conn.headers = {'Accept' => 'application/vnd.api+json'} 
		conn.get '/api/v1/sets'
	end

	private 

	def self.get_connection
		conn = Faraday.new(:url => Rails.application.config.set_url)
	    conn.proxy Rails.application.config.set_url_default_proxy
	    conn.headers = {'Content-Type' => 'application/vnd.api+json'} 
	    conn
	end

end
