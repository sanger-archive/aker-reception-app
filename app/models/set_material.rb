class SetMaterial
	include SetMaterialClient
	include ActiveModel::Model
	include ActiveModel::Serializers::JSON

	validates :name, presence: true	

	attr_accessor :name

	def attributes=(hash)
	    hash.each do |key, value|
	      send("name=", value["attributes"]["name"]) if respond_to?("name=")
	    end
	end

	# params = {:data=>{:type=>"sets", :attributes=>{:name=>MaterialSubmission.first.id}}} 
	def self.create_remote_set(params)
	  	create SetMaterialClient::post(params)
	end

	# Status: 404 - there are no persisted Sets in aker-set-service
	def self.get_remote_set(params)
		get SetMaterialClient::get(params)
	end

	def self.create(obj)
	   filter(obj)
	end

	# from_json creates an instance of Ownership and sets the attributes
	# attributes= method filters out none valid attributes
	def self.filter(hash)
	   set = SetMaterial.new
	   set.from_json(hash.to_json)
	end
end