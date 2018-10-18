require 'ehmdmc_client'

class ManifestsController < ApplicationController

  def schema
    render :json => MatconClient::Material.schema
  end

  # Action to handle validating HMDMC from JavaScript
  def hmdmc_validate
    render :json => EHMDMCClient.validate_hmdmc(params[:hmdmc]).to_json
  end

  def index
    if jwt_provided?
      @pending_manifests = user_manifests.pending
      @active_manifests = user_manifests.active
    else
      @pending_manifests = []
      @active_manifests = []
    end
  end

  def new
    manifest = Manifest.create!(owner_email: current_user.email)

    redirect_to manifest_build_path(
      id: Wicked::FIRST_STEP,
      manifest_id: manifest.id
    )
  end

  def destroy
    @manifest = Manifest.find(params[:id])

    if @manifest.pending? && @manifest.destroy
      flash[:notice] = "Your manifest has been cancelled"
      redirect_to manifests_path
    else
      flash[:error] = "Manifest could not be cancelled"
      redirect_to manifest_build_path manifest_id: @manifest.id
    end
  end

  def show
    @manifest = Manifest.find(params[:id])
  end

private

  def user_manifests
    Manifest.for_user(current_user).order(id: :desc).includes(:labware_type)
  end

end
