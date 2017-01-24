class CompletedSubmissionsController < ApplicationController
	def index
		@unprinted_submissions = MaterialSubmission.active
		@printed_submissions = MaterialSubmission.awaiting
	end

	def print
		completed_submission_ids = params[:completed_submission_ids]
		unless completed_submission_ids
			return print_error "Please specify submissions to print."
		end
		completed_submissions = MaterialSubmission.find(completed_submission_ids.map { |s| s.to_i} )
		unless completed_submissions.all? { |ms| ms.active_or_awaiting? }
			return print_error "Cannot print incomplete submissions."
		end

		# Do print somehow
		Printer.find(name: "d304bc").print_submissions(completed_submissions)

		completed_submissions.each do |ms|
			ms.update_attributes!({ status: MaterialSubmission.AWAITING }) if ms.active?
		end
		redirect_back fallback_location: completed_submissions_url
	end

private
    def print_error(message)
    	redirect_back fallback_location: completed_submissions_url, flash: { error: message }
    end
end
