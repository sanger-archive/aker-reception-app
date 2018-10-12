require 'action_controller'
class MockedTaxonomyServiceController < ActionController::Base
  def taxonomy_endpoint
    taxid = {
      "taxId": params[:id],
      "scientificName": "Some specie name",
    }

    render :json => taxid
  end
end

def mock_taxonomy_service
  Rails.application.routes.draw do
    Rails.application.reload_routes!

    get Rails.configuration.taxonomy_service_url+'/:id', to: "mocked_taxonomy_service#taxonomy_endpoint"
  end
end