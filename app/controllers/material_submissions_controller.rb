class MaterialSubmissionsController < ApplicationController
  before_action :authenticate_user!

  def schema
    render :json => Schema.get
  end

  def index
    @pending_material_submissions = MaterialSubmission.pending
    @active_material_submissions = MaterialSubmission.active
  end

  def new
    material_submission = MaterialSubmission.create

    redirect_to material_submission_build_path(
      id: Wicked::FIRST_STEP,
      material_submission_id: material_submission.id
    )
  end

  def destroy
    @material_submission = MaterialSubmission.find(params[:id])

    if @material_submission.destroy
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

end
