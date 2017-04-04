class SubmissionsController < ApplicationController

  include Wicked::Wizard
  steps :labware, :provenance, :dispatch

  before_action :set_status, only: [:update]
  before_action :authenticate_user!

  def show
    render_wizard
  end

  def update
    @status_success = material_submission.update(material_submission_params)

    unless @status_success
      flash[:error] = 'The material submission could not be updated.'
      render_wizard
      return
    end

    if @status_success && last_step?
      materials = []
      material_submission.labwares.each do |lw|
        lw.wells.each do |well|
          materials.append(well.biomaterial) unless well.biomaterial.nil?
        end
      end

      # Creation of set
      new_set = SetClient::Set.create(name: "Submission #{material_submission.id}")

      # Ownership of materials
      Ownership.create_remote_ownership_batch(ownership_batch_params)

      # Ownership of set
      Ownership.create_remote_ownership(ownership_set_params(new_set.uuid))

      # Adding materials to set
      # set_materials takes an array of uuids
      new_set.set_materials(materials.map(&:uuid))
      new_set.update_attributes(locked: true)

      MaterialSubmissionMailer.submission_confirmation(material_submission).deliver_later
      MaterialSubmissionMailer.notify_contact(material_submission).deliver_later
      material_submission.update_attributes!(status: MaterialSubmission.ACTIVE)
      flash[:notice] = 'Your Submission has been created'
    end

    if params[:material_submission][:status] == 'provenance'
      unless @status_success
        @invalid_data = material_submission.invalid_labwares.map(&:invalid_data).flatten.compact
      end
    else
      render_wizard material_submission
    end
  end

  def claim
    cp = claim_params
    sub_ids = cp[:submission_ids]
    col_id = cp[:collection_id]
    submissions = MaterialSubmission.where(id: sub_ids)
    materials = submissions_biomaterials(submissions)
    SetClient::Set.find(col_id).first.set_materials(materials.map(&:uuid))
    submissions.update_all(status: MaterialSubmission.CLAIMED)
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
      :supply_labwares, :no_of_labwares_required, :status, :labware_type_id, :address, :contact_id, labwares_attributes: [
        :id,
        :uuid,
        wells_attributes: [
          :id,
          :position,
          biomaterial_attributes: [ :id, :supplier_name, :donor_name, :gender, :common_name, :phenotype ]]
      ]
    )
  end

  def claim_params
    {
      submission_ids: params.require(:submission_ids),
      collection_id: params.require(:collection_id),
    }
  end

  def submissions_biomaterials(submissions)
    submissions.flat_map(&:labwares).flat_map(&:biomaterials)
  end

  def set_status
    params[:material_submission][:status] = step.to_s
  end

  def ownership_batch_params
    owner = material_submission.user.email
    bios = material_submission.labwares.flat_map &:biomaterials
    bios.compact.map { |bio| { model_id: bio.uuid, model_type: 'biomaterial', owner_id: owner }}
  end

  def ownership_set_params(set_uuid)
    owner = material_submission.user.email
    {model_id: set_uuid, model_type: 'set', owner_id: owner}
  end

end
