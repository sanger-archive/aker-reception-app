class MaterialReceptionsController < ApplicationController
  def index
    @material_receptions = MaterialReception.all
    @material_reception = MaterialReception.new
  end

  def create
    @material_reception = MaterialReception.create(material_reception_params)
    @material_reception.save
    render json: @material_reception.presenter
  end

  private
  def material_reception_params
    params.require(:material_reception).permit(:barcode_value)
  end
end
