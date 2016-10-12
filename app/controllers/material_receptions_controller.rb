class MaterialReceptionsController < ApplicationController
  def index
    @material_receptions = MaterialReception.all
  end

  def new
    @material_reception = MaterialReception.new
  end

  def create
    @material_reception = MaterialReception.create!(material_reception_params)
    redirect_to material_receptions_path
  end

  private
  def material_reception_params
    params.require(:material_reception).permit(:barcode)
  end
end
