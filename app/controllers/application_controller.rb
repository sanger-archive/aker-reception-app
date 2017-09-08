require 'event_message'

class ApplicationController < ActionController::Base

  protect_from_forgery with: :exception

  include AkerAuthenticationGem::AuthController
  include JWTCredentials


  rescue_from AkerPermissionGem::NotAuthorized do |e|
    respond_to do |format|
      format.html { redirect_to root_path, alert: e.message }
    end
  end

  # creates and publishes (sends) a message
  def send_message_to_queue(sender)
    if sender.is_a?(MaterialSubmission)
      message = EventMessage.new(submission: sender)
    elsif sender.is_a?(MaterialReception)
      message = EventMessage.new(reception: sender)
    end
    EventService.publish(message)
  end
end
