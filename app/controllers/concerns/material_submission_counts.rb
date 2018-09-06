module MaterialSubmissionCounts
  extend ActiveSupport::Concern

  included do
    helper_method :printable_count, :dispatchable_count
  end

  private

  def printable_count
    @printable_count ||= MaterialSubmission.active.count
  end

  def dispatchable_count
    @dispatchable_count ||= MaterialSubmission.printed.not_dispatched.count
  end

end