# Service to deal with inputting HMDMC for human samples
class EthicsService

  def initialize(submission, flash)
    @submission = submission
    @flash = flash
  end

  def update(ethics_params, by_user)
    if !@submission.any_human_material?
      return error 'This submission is not listed as including human material.'
    end

    confirmed_not_req = (ethics_params[:confirm_hmdmc_not_required].to_i == 1)

    if confirmed_not_req
      @submission.set_hmdmc_not_required(by_user)
    else
      return error 'Either "Not required" or an HMDMC number must be specified per sample.'
    end

    @submission.labwares.each { |lw| lw.save! }
    @submission.update_attributes!(status: 'dispatch')

    return true
  end

  private

  def error(message)
    @flash[:error] = message
    false
  end
end
