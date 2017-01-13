class SetMaterial
	include SetMaterialClient
	include ActiveModel::Model
	include ActiveModel::Serializers::JSON

	validates :name, presence: true	

	attr_accessor :id, :name

	# params = {:data=>{:type=>"sets", :attributes=>{:name=>MaterialSubmission.first.id}}} 
	def self.create_remote_set(params)
	  	create SetMaterialClient::post(params)
	end

	# Status: 402 - there are no persisted Sets in aker-set-service
	def self.get_remote_set(params)
		get SetMaterialClient::get(params)
	end

	def self.create(obj)
	  	new filter(obj)
	end

	private 
	
	def self.filter(h, k = [])
		new_hash = {}
		h.each_pair do |key, val|
			if val.is_a?(Hash)
				new_hash.merge!(filter(val))
			else
				new_hash[key] = val
			end
		end
		new_hash.select { |k, _| ['id', 'name'].include? k}
	end

end