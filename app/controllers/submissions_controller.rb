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

      new_set = SetMaterial.create_remote_set(material_submission.id)
      SetMaterial.add_materials_to_set(new_set.uuid, materials)
      puts "new set uuid: #{new_set.uuid}"

      flash[:notice] = 'Your Submission has been created'
      MaterialSubmissionMailer.submission_confirmation(material_submission).deliver_later
      MaterialSubmissionMailer.notify_contact(material_submission).deliver_later

      # Creation of set
      new_set_material = SetMaterial.create_remote_set(material_submission.id)

      # Ownership of materials
      Ownership.create_remote_ownership_batch(ownership_batch_params)

      # Ownership of set
      Ownership.create_remote_ownership(ownership_set_params(new_set_material.uuid))

      # Adding materials to set
      SetMaterial.add_materials_to_set(new_set_material.uuid, materials)
      set_material = SetMaterial.get_remote_set_with_materials(new_set_material.uuid)

      
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

  def ownership_batch_params
    owner = material_submission.email
    bios = material_submission.labwares.flat_map &:biomaterials
    bios.compact.map { |bio| { model_id: bio.uuid, model_type: 'biomaterial', owner_id: owner }}
  end

  def ownership_set_params(set_uuid)
    owner = material_submission.email
    {model_id: set_uuid, model_type: 'set', owner_id: owner}
  end

end
