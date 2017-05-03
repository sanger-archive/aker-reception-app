class SubmissionsController < ApplicationController

  include Wicked::Wizard
  steps :labware, :provenance, :dispatch

  def show
    render_wizard
  end

  def update
    unless material_submission.pending?
      flash[:error] = "This submission cannot be updated."
      render_wizard
      return
    end
    if params[:id]=="provenance"
      labware_params = params["material_submission"]["labware"]
      service = ProvenanceService.new(material_schema)

      @status_success, @invalid_data = service.set_biomaterial_data(material_submission, labware_params)
      # Return here so we don't advance to the next step if we're just changing tabs
      if params["material_submission"]["change_tab"]
        render_wizard
        return
      end
      if @status_success
        @status_success = material_submission.update(material_submission_params)
      end
    else
      @status_success = material_submission.update(material_submission_params)
    end

    unless @status_success
      flash[:error] = 'The material submission could not be updated.'
      render_wizard
      return
    end

    if last_step?
      materials = []
      material_submission.labwares.each do |lw|
        lw.wells.each do |well|
          materials.append(well.biomaterial) unless well.biomaterial.nil?
        end
      end

      # Creation of set
      new_set = SetClient::Set.create(name: "Submission #{material_submission.id}", owner_id: material_submission.contact.email)

      # Adding materials to set
      # set_materials takes an array of uuids
      new_set.set_materials(materials.compact.map(&:uuid))
      new_set.update_attributes(locked: true)

      MaterialSubmissionMailer.submission_confirmation(material_submission).deliver_later
      MaterialSubmissionMailer.notify_contact(material_submission).deliver_later
      flash[:notice] = 'Your Submission has been created'
    end
    material_submission.update_attributes(status: get_status)
    render_wizard material_submission
  end

  # receive biomaterial data, validate it and save it in the labware's json column
  def biomaterial_data

    # Make sure we don't let anyone update the data after the wizard has completed
    raise "This submission cannot be updated." unless material_submission.pending?

    labware_params = params["material_submission"]["labware"]
    service = ProvenanceService.new(material_schema)
    @update_successful, @invalid_data = service.set_biomaterial_data(material_submission, labware_params)

    if @update_successful && !params["material_submission"]["change_tab"]
      @update_successful = material_submission.update_attributes(status: :dispatch)
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

  def material_schema
    MatconClient::Material.schema.body
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

  helper_method :material_submission, :last_step?, :first_step?, :material_schema, :labware_at_index

private

  def material_submission_params
    params.require(:material_submission).permit(
      :supply_labwares, :no_of_labwares_required, :status, :labware_type_id, :address, :contact_id, :labware
    )
  end

  def claim_params
    {
      submission_ids: params.require(:submission_ids),
      collection_id: params.require(:collection_id),
    }
  end

  def submissions_biomaterials(submissions)
    submissions.flat_map(&:labwares).flat_map(&:biomaterials).compact
  end

  def get_status
    return last_step? ? MaterialSubmission.ACTIVE : step.to_s
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

  def labware_at_index(index)
    material_submission.labwares.select { |lw| lw.labware_index==index }.first
  end

end
