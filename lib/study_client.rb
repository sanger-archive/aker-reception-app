require 'faraday'

module StudyClient

	def self.get_set_uuids
		filter_uuids JSON.parse(get_connection.get('/api/v1/collections').body)
	end

  	private

	def self.get_connection
		conn = Faraday.new(:url => Rails.application.config.collections_url) do |faraday|
			faraday.proxy Rails.application.config.collections_url
			faraday.request  :url_encoded
			faraday.response :logger
			faraday.adapter  Faraday.default_adapter
		end
		conn.headers = {'Accept' => 'application/vnd.api+json'}
		conn
	end

	def self.filter_uuids(obj)
		uuids = [] 
		obj["data"].each do |set| 
			uuids.push(set["attributes"]["set-id"]) 
		end
		uuids
	end 
end