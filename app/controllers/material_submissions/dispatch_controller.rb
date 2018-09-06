class MaterialSubmissions::DispatchController < ApplicationController
  include MaterialSubmissionCounts

  before_action :check_ssr_membership, :material_submissions

  def index
  end

  def create
    if params[:material_submission_ids].blank?
      flash.now[:alert] = "You must select at least one Submission to dispatch."
    elsif dispatch_material_submissions
      flash.now[:success] = success_message
    else
      flash.now[:alert] = "Submissions could not be dispatched."
    end
    render :index
  end

private

  def material_submissions
    @material_submissions ||= if show_dispatched?
        MaterialSubmission.dispatched.order(dispatch_date: :desc)
      else
        MaterialSubmission.printed.not_dispatched
      end
  end

  def show_dispatched?
    @show_dispatched ||= params[:status] == 'dispatched'
  end
  helper_method :show_dispatched?

  def selected_material_submissions
    @selected_material_submissions ||= MaterialSubmission.where(id: params[:material_submission_ids])
  end

  def dispatch_material_submissions
    begin
      update_dispatch_dates!
      return true
    rescue
      return false
    end
  end

  def update_dispatch_dates!
    MaterialSubmission.transaction do
      selected_material_submissions.each(&:dispatch!)
    end
  end

  def success_message
    "#{'Submission'.pluralize(selected_material_submissions.count)} #{selected_material_submission_ids} dispatched."
  end

  def selected_material_submission_ids
    selected_material_submissions.map(&:id).join(', ')
  end

end
