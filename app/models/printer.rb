class Printer < ApplicationRecord
	include Printables::Group

	validates :name, presence: true, uniqueness: true
	validates :label_type, presence: true

	def self.PLATE_TEMPLATE
		"aker_code128_96plate"
	end
	def self.TUBE_TEMPLATE
		"aker_code128_1dtube"
	end

	def print_submissions(submissions)
		return true if Rails.configuration.printing_disabled
		print_printables(submissions.flat_map { |submission| submission_to_printables(submission) })
	end
	def print_printables(printables)
		if label_type=='Plate'
			print_plates(name, Printer.PLATE_TEMPLATE, printables)
		else
			print_tubes(name, Printer.TUBE_TEMPLATE, printables)
		end
	end

private
	def submission_to_printables(submission)
		submission.labwares.map.with_index(1) do |lw,i|
			{
				barcode: lw.barcode,
				sanger_human_barcode: lw.barcode,
				date: Date.today.to_s,
				collaborator_email: submission.email,
				uricode: '', # Don't know what this is supposed to be
				number: i,
				total_number: submission.labwares.length,
				num_prints: lw.print_count+1,
			}
		end
	end
end
