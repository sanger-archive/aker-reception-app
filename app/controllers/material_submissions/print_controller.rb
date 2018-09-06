class MaterialSubmissions::PrintController < ApplicationController
  include MaterialSubmissionCounts

  before_action :check_ssr_membership, :material_submissions, :printers, :show_printed?
  before_action :printer, only: [:create]

  # GET /material_submissions/print
  def index
  end

  # POST /material_submissions/print
  def create
    if params[:material_submission_ids].blank?
      flash.now[:alert] = "You must select at least one Submission to print."
    elsif print_submissions
      redirect_to material_submissions_dispatch_index_path, notice: success_notice and return
    else
      flash.now[:alert] = failure_alert
    end
    render :index
  end

private

  def material_submissions
    @material_submissions = show_printed? ? MaterialSubmission.printed : MaterialSubmission.active
  end

  def show_printed?
    @show_printed ||= params[:status] == "printed"
  end
  helper_method :show_printed?

  def printers
    @printers ||= Printer.all
  end

  def print_submissions
    if printer.print_submissions(selected_material_submissions)
      return update_submissions_and_labware_count!
    end
    return false
  end

  def printer
    @printer ||= Printer.find_by(name: params[:printer][:name])
  end

  def selected_material_submissions
    MaterialSubmission.where(id: params[:material_submission_ids])
  end

  def update_submissions_and_labware_count!
    begin
      ActiveRecord::Base.transaction do
        active_material_submissions.each do |material_submission|
          material_submission.update_attributes!(status: MaterialSubmission.PRINTED)
          material_submission.labwares.each { |lw| lw.increment_print_count! }
        end
      end
      return true
    rescue
      return false
    end
  end

  def active_material_submissions
    selected_material_submissions.where(status: "active")
  end

  def success_notice
    "Labels for labware from #{'Submission'.pluralize(selected_material_submissions.count)} " \
    "#{material_submission_ids.join(", ")} sent to #{printer.name}."
  end

  def material_submission_ids
    selected_material_submissions.map(&:id)
  end

  def failure_alert
    "There was an error printing your labels. Please try again, or contact an administrator."
  end

end
