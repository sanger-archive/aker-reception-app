module DispatchSteps
  class ClaimClaimableLabware

    attr_reader :submissions

    def initialize(submissions)
      @submissions = submissions
    end

    def up
      ActiveRecord::Base.transaction { submissions.each(&:claim_claimable_labwares) }
    end

    # noop
    def down
    end

  end
end