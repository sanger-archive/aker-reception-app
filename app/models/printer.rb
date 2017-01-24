class Printer < ApplicationRecord
	include Printables::Group

	def self.PLATE_TEMPLATE
		"aker_code128_96plate"
	end
	def self.TUBE_TEMPLATE
		"aker_code128_1dtube"
	end

	def print_submissions(submissions)
		print_printables(submissions.flat_map { |submission| submission_to_printables(submission) })
	end
	def print_printables(printables)
		if @label_type=='Plate'
			print_plates(@name, PLATE_TEMPLATE, printables)
		else
			print_tubes(@name, TUBE_TEMPLATE, printables)
		end
	end

private
	def submission_to_printables(submission)
		submission.labwares.map.with_index(1) do |lw,i|
			{
				barcode: lw.barcode.value,
				sanger_human_barcode: lw.barcode.value,
				date: Date.today.to_s,
				collaborator_email: submission.email,
				uricode: '', # Don't know what this is supposed to be
				number: i,
				total_number: submission.labwares.length,
				num_prints: '', # Don't know what this is supposed to be
			}
		end
	end
end
