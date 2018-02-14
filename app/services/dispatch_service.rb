# This service tries to execute a sequence of steps.
# If any of the steps fails, that step and all previous steps should be rolled back.
# If all steps succeed, process should return true.
# If any steps fail, and roll back is successful, process should return false.
class DispatchService

  def process(steps)
    passed = []
    current_step = nil
    begin
      steps.each do |step|
        current_step = step
        current_step.up
        passed.push(current_step)
        current_step = nil
      end
    rescue => e
      Rails.logger.error "A step failed in the dispatch service:"
      Rails.logger.error e
      e.backtrace.each { |x| Rails.logger.error x}
      raise
    ensure
      unless current_step.nil?
        # clean up
        current_step.down
        passed.reverse_each do |step|
          step.down
        end
        return false
      end
    end
    return true
  end

end
