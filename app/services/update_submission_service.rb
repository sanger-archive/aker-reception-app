class UpdateSubmissionService

  def initialize(submission, messages)
    @submission = submission
    @messages = messages
  end

  def ready_for_step(step)
    step = step.to_sym
    unless @submission.pending?
      return fail("This submission cannot be updated.")
    end
    return true if step==:labware
    unless @submission.labwares.present? && !(@submission.supply_labwares.nil?)
      return fail("Please go back and complete the labware step before proceeding.")
    end
    return true if step==:provenance
    unless @submission.after_provenance?
      return fail("Please go back and complete the provenance step before proceeding.")
    end
    return true if step==:ethics
    unless @submission.ethical?
      return fail("Please go back and complete the ethics step before proceeding.")
    end
    return true
  end

private

  def fail(message)
    @messages[:error] = message
    return false
  end
end
