require 'ehmdmc_client'

class MaterialSubmissionsController < ApplicationController

  def schema
    render :json => MatconClient::Material.schema
  end

  # Action to handle validating HMDMC from JavaScript
  def hmdmc_validate
    render :json => EHMDMCClient.validate_hmdmc(params[:hmdmc]).to_json
  end

  def index
    if jwt_provided?
      @pending_material_submissions = MaterialSubmission.pending.for_user(current_user).sort_by(&:id).reverse
      @active_material_submissions = MaterialSubmission.active.for_user(current_user).sort_by(&:id).reverse
    else
      @pending_material_submissions = []
      @active_material_submissions = []
    end
  end

  def new
    material_submission = MaterialSubmission.create!(owner_email: current_user.email)

    redirect_to material_submission_build_path(
      id: Wicked::FIRST_STEP,
      material_submission_id: material_submission.id
    )
  end

  def destroy
    @material_submission = MaterialSubmission.find(params[:id])

    if @material_submission.pending? && @material_submission.destroy
      flash[:notice] = "Your manifest has been cancelled"
      redirect_to material_submissions_path
    else
      flash[:error] = "Submission could not be cancelled"
      redirect_to material_submission_build_path material_submission_id: @material_submission.id
    end
  end

  def show
    @material_submission = MaterialSubmission.find(params[:id])
  end

  def edit
    @material_submission = MaterialSubmission.find(params[:id])
  end
end
