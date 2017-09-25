class MaterialSubmissionsController < ApplicationController
  before_action :require_jwt

  def schema
    render :json => MatconClient::Material.schema
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
      flash[:notice] = "Submission Cancelled"
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

  private

  def require_jwt
    unless current_user
      redirect_to Rails.configuration.login_url
    end
  end
end
