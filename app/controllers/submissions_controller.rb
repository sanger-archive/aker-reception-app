class SubmissionsController < ApplicationController
  include Wicked::Wizard
  steps :labware, :provenance, :ethics, :dispatch

  def show
    if step == :ethics && !any_human_material_no_hmdmc?
      skip_step
    end
    render_wizard
  end

  def update
    sub_service = UpdateManifestService.new(manifest, flash)
    unless sub_service.ready_for_step(params[:id])
      render_wizard
      return
    end

    if params[:id] == "ethics"
      return ethics_update
    end

    if params[:id] == "provenance"
      labware_params = params["manifest"]["labware"]
      service = ProvenanceService.new(material_schema)

      @status_success, @invalid_data = service.set_biomaterial_data(manifest,
                                                                    labware_params)
      # Return here so we don't advance to the next step if we're just changing tabs
      if params["manifest"]["change_tab"]
        render_wizard
        return
      end
      if @status_success
        @status_success = manifest.update(manifest_params)
      end
    else
      @status_success = manifest.update(manifest_params.merge(
        status: step.to_s,
        last_step: last_step?))
    end

    unless @status_success
      return error_render 'The manifest could not be updated.'
    end

    if last_step?
      if manifest.status!='dispatch'
        return error_render "Manifest not ready: please check previous steps"
      end
      unless manifest.ethical?
        return error_render "Please go back and check the ethics step before proceeding."
      end

      success = false
      cleanup = false
      begin
        success = DispatchService.new.process([
          DispatchSteps::CreateMaterialsStep.new(manifest),
          DispatchSteps::CreateContainersStep.new(manifest),
          DispatchSteps::CreateSetsStep.new(manifest),
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
          @manifest.broken!
        end
      end

      if success
        flash[:notice] = 'Your manifest has been created'
      elsif cleanup
        flash[:error] = "The Manifest could not be created"
      else
        flash[:error] = "There has been a problem with the Manifest. Please contact support."
      end

      unless success
        render_wizard
        return
      end

      # upon successful Manifest, send an event for the warehouse to pickup
      message = EventMessage.new(manifest: @manifest)
      EventService.publish(message)
    end

    manifest.update_attributes(status: get_next_status) if manifest.valid?
    render_wizard manifest
  end

  # Receive biomaterial data, validate it and save it in the labware's 'contents' column (JSON)
  def biomaterial_data
    # Make sure we don't let anyone update the data after the wizard has completed
    raise "This Manifest cannot be updated." unless manifest.pending?

    labware_params = params["manifest"]["labware"]
    service = ProvenanceService.new(material_schema)
    @update_successful, @invalid_data = service.set_biomaterial_data(manifest,
                                                                     labware_params,
                                                                     current_user)

    if @update_successful && !params["manifest"]["change_tab"]
      @update_successful = manifest.update_attributes(
        status: (any_human_material_no_hmdmc? ? 'ethics' : 'dispatch'))
    end

    if !@update_successful &&
        (manifest.status == 'dispatch' || manifest.status == 'ethics')
      # If the given provenance is incomplete or wrong, make sure they're not in a later step
      #   (because they could have gone back and incorrected the material data).
      manifest.update_attributes(status: :provenance)
    end
  end

  def ethics_update
    service = EthicsService.new(manifest, flash)
    if service.update(ethics_params, current_user.email)
      render_wizard manifest
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

  def previous_step(step = nil)
    pstep = super(step)
    return :provenance if pstep == :ethics && !any_human_material_no_hmdmc?
    return pstep
  end

  def cached_taxonomies
    {}
  end



protected

  def manifest
    @manifest ||= Manifest.find(params[:manifest_id])
  end

  def last_step?
    step == steps.last
  end

  def first_step?
    step == steps.first
  end

  helper_method :manifest, :last_step?, :first_step?, :material_schema, :labware_at_index

private

  def manifest_params
    params.require(:manifest).permit(:supply_labwares,
                                                :supply_decappers,
                                                :no_of_labwares_required,
                                                :status,
                                                :labware_type_id,
                                                :address,
                                                :contact_id,
                                                :labware)
  end

  def ethics_params
    params.permit(:confirm_hmdmc_not_required, :hmdmc_1, :hmdmc_2)
  end

  def get_next_status
    return 'dispatch' if step==:provenance && !any_human_material?
    return last_step? ? Manifest.ACTIVE : next_step.to_s
  end

  def any_human_material?
    manifest&.any_human_material?
  end

  # Check whether there is human material without HMDMC numbers in this manifest
  def any_human_material_no_hmdmc?
    manifest&.any_human_material_no_hmdmc?
  end

  def labware_at_index(index)
    manifest.labwares.select { |lw| lw.labware_index == index }.first
  end

  def finish_wizard_path
    root_path
  end

end
