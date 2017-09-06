class ClaimSubmissionsController < ApplicationController

  def index
    @stamps = StampClient::Stamp.all

    if contact.nil?
      @submissions = []
    else
      @submissions = @contact.material_submissions.where(:status => MaterialSubmission.PRINTED).select(&:ready_for_claim?).sort_by(&:id).reverse
    end
  end

  def create
    claim_service = ClaimService.new(submissions, claim_params[:stamp_id])

    if claim_service.process
      flash[:success] = "#{'Submission'.pluralize(submissions.count)} successfully claimed"
    else
      flash[:error] = claim_service.error
    end

    redirect_to action: 'index'
  end

  helper_method :stamp_summary

  def stamp_summary(stamp)
    "Stamp '#{stamp.name}' from '#{stamp.owner_id}'"
  end

  private

  def submissions
    @submissions ||= MaterialSubmission.where(id: claim_params[:submission_ids], contact: contact)
  end

  def contact
    @contact ||= Contact.from_user(current_user)
  end

  def claim_params
    {
      submission_ids: params.require(:submission_ids).delete_if(&:empty?),
      stamp_id: params.require(:stamp_id)
    }
  end

end
