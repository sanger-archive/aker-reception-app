module AuthenticationHelper
  def current_user
    @current_user ||= create(:user)
  end

  def login(user = nil)
    user = current_user if user.nil?
    allow_any_instance_of(JWTCredentials).to receive(:check_credentials)
    allow_any_instance_of(JWTCredentials).to receive(:current_user).and_return(user)
  end
end