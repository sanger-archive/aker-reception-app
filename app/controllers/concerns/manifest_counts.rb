module ManifestCounts
  extend ActiveSupport::Concern

  included do
    helper_method :printable_count, :printed_count, :dispatchable_count, :dispatched_count
  end

  private

  def printable_count
    @printable_count ||= Manifest.active.count
  end

  def printed_count
    @printed_count ||= Manifest.printed.count
  end

  def dispatchable_count
    @dispatchable_count ||= Manifest.printed.not_dispatched.count
  end

  def dispatched_count
    @dispatched_count ||= Manifest.dispatched.count
  end

end