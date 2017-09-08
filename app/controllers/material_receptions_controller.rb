class MaterialReceptionsController < ApplicationController

  before_action :set_labware, only: :create

  def index
    @material_receptions = MaterialReception.all.sort_by(&:id).reverse
    @material_reception = MaterialReception.new
  end

  def create
    reception_service = ReceptionService.new(labware: @labware)

    if reception_service.process
      material_reception = reception_service.material_reception
      ReceptionMailer.material_reception(material_reception).deliver_later
      send_message_to_queue material_reception
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

end
