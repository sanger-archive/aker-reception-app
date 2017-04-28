class SubmissionsController < ApplicationController

  include Wicked::Wizard
  steps :labware, :provenance, :dispatch

  def show
    render_wizard
  end

  def update
    if params[:id]=="provenance"
      #TODO: Validatation

      success = true
      labwares_data = params["material_submission"]["labware"].each do | labware_key, labware_data |
        labware_index = labware_key.to_i
        labware = material_submission.labwares.select { |lw| lw.labware_index==labware_index }.first
        if labware.nil?
          flash[:error] = 'Wrong labware index received'
          render_wizard
          return
        end
        filtered_data = {}
        labware_data.each do |address, material_data|
          material_data.each do | fieldName, value |
            unless value.blank?
              filtered_data[address] = {} if filtered_data[address].nil?
              filtered_data[address][fieldName] = value.strip()
            end
          end
        end
        filtered_data = nil if filtered_data.empty?
        success &= labware.update_attributes(contents: filtered_data)
      end
      @status_success = success
      # Return here so we don't advance to the next step if we're just changing tabs
      if params["material_submission"]["change_tab"]
        render_wizard
        return
      end
    else
      @status_success = material_submission.update(material_submission_params)
    end

    unless @status_success
      if params[:material_submission][:status] == 'provenance'
        @invalid_data = material_submission.invalid_labwares.map(&:invalid_data).flatten.compact
        return
      end
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

    material_submission.update(status: get_status)
    render_wizard material_submission
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
