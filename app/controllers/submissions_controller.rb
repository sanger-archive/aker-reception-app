class SubmissionsController < ApplicationController
  include Wicked::Wizard
  steps :labware, :provenance, :ethics, :dispatch

  before_action :require_jwt

  def show
    if step==:ethics && !any_human_material?
      skip_step
    end
    render_wizard
  end

  def update
    unless material_submission.pending?
      flash[:error] = "This submission cannot be updated."
      render_wizard
      return
    end

    if params[:id]=="ethics"
      return ethics_update
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
      @status_success = material_submission.update(material_submission_params.merge(status: step.to_s, last_step: last_step?))
    end

    unless @status_success
      return error_render 'The material submission could not be updated.'
    end

    if last_step?
      if material_submission.status!='dispatch'
        return error_render "Submission not ready: please check previous steps"
      end
      unless material_submission.ethical?
        return error_render "Please go back and check the ethics step before proceeding."
      end

      success = false
      cleanup = false
      begin
        success = DispatchService.new.process([
          DispatchSteps::CreateMaterialsStep.new(material_submission),
          DispatchSteps::CreateContainersStep.new(material_submission),
          DispatchSteps::CreateSetsStep.new(material_submission),
          # CreateSetsStep should be last, because it is the least cleanupable
        ])

        cleanup = !success
      rescue => e
        logger.error "*"*70
        logger.error "Error from dispatch service:"
        logger.error e
        logger.error e.backtrace
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

      # upon successful submission, send an event for the warehouse to pickup
      message = EventMessage.new(submission: @material_submission)
      EventService.publish(message)
    end

    material_submission.update_attributes(status: get_next_status) if material_submission.valid?
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
      @update_successful = material_submission.update_attributes(status: (any_human_material? ? 'ethics' : 'dispatch'))
    end

    if !@update_successful && (material_submission.status=='dispatch' || material_submission.status=='ethics')
      # If the given provenance is incomplete or wrong, make sure
      # they're not in a later step (because they could have gone
      # back and incorrected the material data).
      material_submission.update_attributes(status: :provenance)
    end
  end

  def ethics_update
    service = EthicsService.new(material_submission, flash)
    if service.update(ethics_params, current_user.email)
      render_wizard material_submission
    else
      render_wizard
    end
  end

  def error_render(error)
    flash[:error] = error
    render_wizard
  end

  def material_schema
    MatconClient::Material.schema
  end

  def previous_step(step=nil)
    pstep = super(step)
    return :provenance if pstep==:ethics && !any_human_material?
    return pstep
  end


  def finish_wizard_path
    root_path
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

  def ethics_params
    params.permit(:confirm_hmdmc_not_required, :hmdmc_1, :hmdmc_2)
  end

  def get_next_status
    return 'dispatch' if step==:provenance && !any_human_material?
    return last_step? ? MaterialSubmission.ACTIVE : next_step.to_s
  end

  def any_human_material?
    material_submission&.any_human_material?
  end

  def labware_at_index(index)
    material_submission.labwares.select { |lw| lw.labware_index==index }.first
  end

  def require_jwt
    unless current_user
      redirect_to Rails.configuration.login_url
    end
  end

end
