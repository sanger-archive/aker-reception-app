class SetMaterial
	include SetMaterialClient
	include ActiveModel::Model

	validates :name, presence: true	

	# params = {:data=>{:type=>"set", :attributes=>{:name=>"string"}}} 
	# params = {:name => 'set name'}
	def self.create_remote_set(params)
	  	SetMaterialClient::post(params)
	end

	# def self.get_remote_set
	# 	get
	# end
end