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

		completed_submissions.each do |ms|
			ms.update_attributes!({ status: MaterialSubmission.AWAITING }) if ms.active?
		end
		redirect_back fallback_location: completed_submissions_url
	end

private
    def print_error(message)
    	redirect_back fallback_location: completed_submissions_url, flash: { error: message }
    end
	def badrequest(message)
		error = {
			status: 400,
			message: message
		}
		render json: error, status: :bad_request
	end
end
