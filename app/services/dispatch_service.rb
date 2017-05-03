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
      puts "*"*70
      puts e
      puts e.backtrace
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
