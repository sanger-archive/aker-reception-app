# Service to deal with inputting hmdmc for human samples
class EthicsService

  def initialize(submission, flash)
    @submission = submission
    @flash = flash
  end

  def update(ethics_params, by_user)
    return error 'This submission is not listed as including human material.' unless @submission.any_human_material?
    confirmed_not_req = (ethics_params[:confirm_hmdmc_not_required].to_i==1)
    hmdmc_1 = ethics_params[:hmdmc_1]
    hmdmc_2 = ethics_params[:hmdmc_2]
    if confirmed_not_req && (hmdmc_1.present? || hmdmc_2.present?)
      return error '"Not required" and HMDMC number both specified. Please choose one or the other.'
    end
    if hmdmc_1.present? != hmdmc_2.present?
      return error 'Both parts of the HMDMC number must be specified.'
    end
    if !confirmed_not_req && !hmdmc_1.present?
      return error 'Either "Not required" or an HMDMC number must be specified.'
    end

    if confirmed_not_req
      @submission.set_hmdmc_not_required(by_user)
    else
      hmdmc = hmdmc_1+'/'+hmdmc_2
      unless hmdmc.match(/^[0-9]{2}\/[0-9]{3}$/)
        return error 'HMDMC number must be of the format ##/###'
      end
      @submission.set_hmdmc(hmdmc, by_user)
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
