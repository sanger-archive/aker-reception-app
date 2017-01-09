module BiomaterialClient
  def site
	 RestClient::Resource.new(Rails.configuration.materials_service_url)
  end

  def create(data)
	self.site["materials"].post(data, :content_type => 'text/json')
  end

  def update(data)
	self.site["materials"][data[:uuid]].put(data, :content_type => 'text/json')
  end

  def find(uuid)
  	return nil if uuid.nil?
  	self.site["materials"][uuid].get(:content_type => 'text/json')
  end
end