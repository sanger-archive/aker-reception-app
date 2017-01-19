class SubmissionsController < ApplicationController

  include Wicked::Wizard
  steps :labware, :provenance, :dispatch

  before_action :set_status, only: [:update]

  def show
    render_wizard
  end

  def update
    @status_success = material_submission.update_attributes(material_submission_params)
    if @status_success && last_step?
      materials = []
      material_submission.labwares.each do |lw|
        lw.wells.each do |well|
          materials.append(well.biomaterial)
        end
      end

      flash[:notice] = 'Your Submission has been created'
      MaterialSubmissionMailer.submission_confirmation(material_submission).deliver_later
      MaterialSubmissionMailer.notify_contact(material_submission).deliver_later

      new_set = SetMaterial.create_remote_set(material_submission.id)
      SetMaterial.add_materials_to_set(new_set.uuid, materials)
      puts "new set uuid: #{new_set.uuid}"
    end

    if params[:material_submission][:status] == 'provenance'
      unless @status_success
        @invalid_data = material_submission.invalid_labwares.map(&:invalid_data).flatten.compact
      end
    else
      render_wizard material_submission
    end

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
      :supply_labwares, :no_of_labwares_required, :status, :labware_type_id, :address, :email, :contact_id, labwares_attributes: [
        :id,
        wells_attributes: [
          :id,
          :position,
          biomaterial_attributes: [ :id, :supplier_name, :donor_name, :gender, :common_name, :phenotype ]]
      ]
    )
  end

  def set_status
    params[:material_submission][:status] = last_step? ? MaterialSubmission.ACTIVE : step.to_s
  end


end
