class CompletedSubmissionsController < ApplicationController
	def index
		@unprinted_submissions = MaterialSubmission.active
		@printed_submissions = MaterialSubmission.awaiting
		@printers = Printer.all
	end

	def print
		printparams = print_params

		completed_submissions = MaterialSubmission.find(printparams[:completed_submission_ids])
		printer = Printer.find_by(name: printparams[:printer_name])

		unless printer.print_submissions(completed_submissions)
			return print_error "Printing failed."
		end

		completed_submissions.each do |ms|
			ms.update_attributes!({ status: MaterialSubmission.AWAITING }) if ms.active?
			ms.labwares.each { |lw| lw.barcode.increment!(:print_count) }
		end
		redirect_back fallback_location: completed_submissions_url, flash: { notice: "Print issued."}
	end

private
	def print_params
		{
			completed_submission_ids: params.require(:completed_submission_ids).map { |s| s.to_i },
			printer_name: params.require(:printer).require(:name)
		}
	end
    def print_error(message)
    	redirect_back fallback_location: completed_submissions_url, flash: { error: message }
    end
end
