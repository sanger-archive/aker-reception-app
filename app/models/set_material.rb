class SetMaterial
	include SetMaterialClient
	include ActiveModel::Model

	validates :name, presence: true	

	# params = {:data=>{:type=>"set", :attributes=>{:name=>"string"}}} 
	def create_remote_set(params)
	  	post(params)
	end

	def get_remote_set
		get
	end
end