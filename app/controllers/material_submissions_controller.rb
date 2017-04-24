class MaterialSubmissionsController < ApplicationController

  def schema
    render :json => Schema.get
  end

  def index
    if user_signed_in?
      @pending_material_submissions = MaterialSubmission.pending.for_user(current_user)
      @active_material_submissions = MaterialSubmission.active.for_user(current_user)
    else
      @pending_material_submissions = []
      @active_material_submissions = []
    end
  end

  def new
    material_submission = MaterialSubmission.create!(user: current_user)

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
