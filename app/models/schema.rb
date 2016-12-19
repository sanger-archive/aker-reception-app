require 'rest-client'

class Schema

  def self.site
	 RestClient::Resource.new(Rails.configuration.materials_service_url)
  end

  def self.get
	 Schema.site["materials"]["schema"].get :content_type => 'text/json'  	
  end

end
