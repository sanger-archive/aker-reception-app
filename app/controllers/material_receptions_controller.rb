class MaterialReceptionsController < ApplicationController
  def index
    @material_receptions = MaterialReception.all
    @material_reception = MaterialReception.new
  end

  def create
    @material_reception = MaterialReception.create(material_reception_params)
    if @material_reception.save
      ReceptionMailer.material_reception(@material_reception).deliver_later
    end
    if @material_reception.complete_set?
      ReceptionMailer.complete_set(@material_reception).deliver_later
    end
    render json: @material_reception.presenter
  end

  private
  def material_reception_params
    params.require(:material_reception).permit(:barcode_value)
  end
end
