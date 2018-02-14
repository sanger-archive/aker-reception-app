require 'event_message'

class ApplicationController < ActionController::Base
  protect_from_forgery with: :exception

  include JWTCredentials

  rescue_from AkerPermissionGem::NotAuthorized do |e|
    respond_to do |format|
      format.html { redirect_to root_path, alert: e.message }
    end
  end

  helper_method :jwt_provided?
  helper_method :current_user

  def check_ssr_membership
    if !current_user.groups.any? { |group| group.in? Rails.configuration.ssr_groups }
      render :permission_denied
    end
  end

end
