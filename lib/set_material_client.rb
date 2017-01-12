require 'faraday'

module SetMaterialClient

	def post(params)
		conn = Faraday.new(:url => get_set_url)
		conn.proxy Rails.application.config.set_url_default_proxy
		conn.headers = {'Content-Type' => 'application/vnd.api+json'} 
		conn.post '/api/v1/sets', params.to_json
	end

	def get
		conn = Faraday.new(:url => get_set_proxy)
		conn.proxy Rails.application.config.set_url_default_proxy
		conn.headers = {'Accept' => 'application/vnd.api+json'} 
		conn.get '/api/v1/sets'
	end

	private 

	def get_set_url
		Rails.application.config.set_url
	end

	def get_set_proxy
		Rails.application.config.set_url
	end
end
