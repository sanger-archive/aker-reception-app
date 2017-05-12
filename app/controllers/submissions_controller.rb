require 'dispatch_steps/create_materials_step'
require 'dispatch_steps/create_sets_step'
require 'dispatch_steps/create_containers_step'
require 'dispatch_steps/fail_step'

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
      @status_success = material_submission.update(material_submission_params.merge(status: step.to_s))
    end

    unless @status_success
      flash[:error] = 'The material submission could not be updated.'
      render_wizard
      return
    end

    if last_step?
      if material_submission.status!='dispatch'
        flash[:error] = "Submission not ready: please check previous steps"
        render_wizard
        return
      end

      success = false
      cleanup = false
      begin
        success = DispatchService.new.process([
          CreateMaterialsStep.new(material_submission),
          CreateContainersStep.new(material_submission),
          CreateSetsStep.new(material_submission),
          # CreateSetsStep should be last, because it is the least cleanupable
        ])

        cleanup = !success
      rescue => e
        puts "*"*70
        puts "Error from dispatch service:"
        puts e
        puts e.backtrace
      ensure
        if !success && !cleanup
          @material_submission.broken!
        end
      end

      if success
        flash[:notice] = 'Your submission has been created'
      elsif cleanup
        flash[:error] = "The submission could not be created"
      else
        flash[:error] = "There has been a problem with the submission. Please contact support."
      end

      unless success
        render_wizard
        return
      end

      MaterialSubmissionMailer.submission_confirmation(material_submission).deliver_later
      MaterialSubmissionMailer.notify_contact(material_submission).deliver_later

    end

    material_submission.update_attributes(status: get_next_status) if material_submission.valid?
    render_wizard material_submission
    @material_submission = nil
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

    if !@update_successful && material_submission.status=='dispatch'
      # If the given provenance is incomplete or wrong, make sure
      # they're not in the last step (because they could have gone
      # back and incorrected the material data).
      material_submission.update_attributes(status: :provenance)
    end
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

  def get_next_status
    return last_step? ? MaterialSubmission.ACTIVE : next_step.to_s
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
