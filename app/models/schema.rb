require 'faraday'

class Schema

	def self.get
		conn = get_connection
		JSON.parse(get_connection.get('/materials/schema').body)
	end

	def self.get_connection
		conn = Faraday.new(:url => Rails.application.config.material_url)
	    conn.proxy Rails.application.config.material_url
	    conn.headers = {'Content-Type' => 'text/json'}
	    conn
	end

end
