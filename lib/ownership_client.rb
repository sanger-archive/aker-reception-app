require 'rest_client'

module OwnershipClient
  def post(params)
	RestClient.post(Rails.application.config.ownership_url, params, {content_type: :json, accept: :json})
  end

  def put(params)
	RestClient.post(Rails.application.config.ownership_url, params, {content_type: :json, accept: :json})
  end

  def get(id)
  	RestClient.get(Rails.application.config.ownership_url+'/'+id, {content_type: :json, accept: :json})
  end 

  def delete
  	raise 'Not implemented'
  end
end