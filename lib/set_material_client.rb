require 'faraday'

module SetMaterialClient

	def self.post(submission_id)
		data = {:data=>{:type=>"sets", :attributes=>{:name=>submission_id}}} 
		conn = get_connection
		JSON.parse(conn.post('/api/v1/sets', data.to_json).body)
	end

	def self.add_materials(set_uuid, materials)
		data = {:data => materials.compact.map{|m| {:id => m.uuid, :type => 'materials'}}}
		conn = get_connection
		get_connection.post('/api/v1/sets/'+set_uuid+'/relationships/materials', data.to_json)
	end

	def self.get_with_materials(set_uuid)
		conn = get_connection
		conn.headers = {'Accept' => 'application/vnd.api+json'} 
	 	JSON.parse(get_connection.get('/api/v1/sets/'+set_uuid+'/relationships/materials').body)
	end

	private 

	def self.get_connection
		conn = Faraday.new(:url => Rails.application.config.set_url)
	    conn.proxy Rails.application.config.set_url_default_proxy
	    conn.headers = {'Content-Type' => 'application/vnd.api+json'} 
	    conn
	end

end
