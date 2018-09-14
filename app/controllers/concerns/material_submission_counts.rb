module MaterialSubmissionCounts
  extend ActiveSupport::Concern

  included do
    helper_method :printable_count, :printed_count, :dispatchable_count, :dispatched_count
  end

  private

  def printable_count
    @printable_count ||= MaterialSubmission.active.count
  end

  def printed_count
    @printed_count ||= MaterialSubmission.printed.count
  end

  def dispatchable_count
    @dispatchable_count ||= MaterialSubmission.printed.not_dispatched.count
  end

  def dispatched_count
    @dispatched_count ||= MaterialSubmission.dispatched.count
  end

end