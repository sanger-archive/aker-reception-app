class SubmissionsController < ApplicationController

  include Wicked::Wizard
  steps :labware, :provenance, :dispatch

  def show
    render_wizard
  end

  def update
    params[:material_submission][:status] = step.to_s
    params[:material_submission][:status] = MaterialSubmission.ACTIVE if last_step?

    if material_submission.update_attributes(material_submission_params) && last_step?
      flash[:notice] = 'Your Submission has been created'
    end

    render_wizard material_submission
  end

  protected

  def material_submission
    @material_submission ||= MaterialSubmission.find(params[:material_submission_id])
  end

  def last_step?
    step == steps.last
  end

  def first_step?
    step == steps.first
  end

  helper_method :material_submission, :last_step?, :first_step?

  private

  def material_submission_params
    params.require(:material_submission).permit(
      :supply_labwares, :no_of_labwares_required, :status, :labware_type_id, :address, contact_attributes: [:email], labwares_attributes: [
        :id,
        wells_attributes: [
          :id,
          :position,
          biomaterial_attributes: [ :id, :supplier_name, :donor_name, :gender, :common_name, :phenotype ]]
      ]
    )
  end


end
