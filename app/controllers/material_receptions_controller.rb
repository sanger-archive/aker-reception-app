class MaterialReceptionsController < ApplicationController

  before_action :set_labware, only: :create
  before_action :require_jwt

  def index
    @material_receptions = MaterialReception.all.sort_by(&:id).reverse
    @material_reception = MaterialReception.new
  end

  def create
    reception_service = ReceptionService.new(labware: @labware)

    if reception_service.process
      material_reception = reception_service.material_reception
      ReceptionMailer.material_reception(material_reception).deliver_later

      # send message upon successful reception
      message = EventMessage.new(reception: material_reception)
      EventService.publish(message)
    end

    render json: reception_service.presenter
  end

  private

  def material_reception_params
    params.require(:material_reception).permit(:barcode_value)
  end

  def set_labware
    @labware ||= Labware.find_by(barcode: material_reception_params[:barcode_value])
  end

  def require_jwt
    unless current_user
      redirect_to Rails.configuration.login_url
    end
  end

end
