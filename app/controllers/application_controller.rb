class ApplicationController < ActionController::Base

  before_action :apply_credentials

private

	def apply_credentials
		RequestStore.store[:x_authorisation] = get_user
	end

	def get_user
		session["user"]
	end

  rescue_from DeviseLdapAuthenticatable::LdapException do |exception|
    render :text => exception, :status => 500
  end

  protect_from_forgery with: :exception
end
