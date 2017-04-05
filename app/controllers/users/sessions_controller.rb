class Users::SessionsController < Devise::SessionsController
  after_action :store_session_data, only: [:create]
  before_action :add_email_to_user, only: [:create]

  protected

  def add_email_to_user
    request.parameters["user"]["email"] += '@sanger.ac.uk' unless request.parameters["user"]["email"].include?('@')
  end

  def store_session_data
    user_data = {
      "groups" => current_user.fetch_groups,
      "user" => current_user,
    }
    session["user"] = user_data
  end

end