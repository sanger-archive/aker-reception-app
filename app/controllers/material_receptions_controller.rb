class MaterialReceptionsController < ApplicationController
  before_action :authenticate_user!

  before_filter :set_labware, only: :create

  def index
    @material_receptions = MaterialReception.all
    @material_reception = MaterialReception.new
  end

  def create
    @material_reception = MaterialReception.create(:labware_id => @labware_id)

    if @material_reception.save
      ReceptionMailer.material_reception(@material_reception).deliver_later
      # Only check if the set is complete is material_reception saved
      if @material_reception.complete_set?
        ReceptionMailer.complete_set(@material_reception).deliver_later
      end
    end
    render json: @material_reception.presenter
  end

  private
  def material_reception_params
    params.require(:material_reception).permit(:barcode_value)
  end

  def set_labware
    @labware = Labware.with_barcode(material_reception_params[:barcode_value]).first
    @labware_id = @labware ? @labware.uuid : nil
  end

end
