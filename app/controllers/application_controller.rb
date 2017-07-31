class ApplicationController < ActionController::Base

  protect_from_forgery with: :exception

  include AkerAuthenticationGem::AuthController
  include JWTCredentials


  rescue_from AkerPermissionGem::NotAuthorized do |e|
    respond_to do |format|
      format.html { redirect_to root_path, alert: e.message }
    end
  end
end
