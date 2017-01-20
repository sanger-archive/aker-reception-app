require "material_service_client/version"

module MaterialServiceClient
	def self.post(data)
		conn = get_connection
		JSON.parse(conn.post('/materials', data.to_json).body)
	end

	def self.put(data)
		uuid = data[:uuid]
		data_to_send = data.reject{|k,v| k.to_sym == :uuid}

		conn = get_connection
		JSON.parse(conn.put('/materials/'+uuid, data_to_send.to_json).body)
	end

	def self.get(uuid)
		return nil if uuid.nil?
		conn = get_connection
		JSON.parse(conn.get('/materials/'+uuid).body)
	end

	def self.valid?(uuids)
		conn = get_connection
		data = { materials: uuids }

		response = conn.post('/materials/validate', data.to_json)
		response.body == 'ok'
	end

	private

	def self.get_connection
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
