module Printables::Group

  def print_tubes(printer_name, label_template_name, printables)
	PMB::PrintJob.new(printer_name: printer_name,
		label_template_id: LabelTemplate.find_by_name(label_template_name).id,
		labels: {body: printables.map do |printable|
			{:main_label => tube_layout(printable)}
		end
	}).save
  end

  def print_plates(printer_name, label_template_name, printables)
	PMB::PrintJob.new(printer_name: printer_name,
		label_template_id: LabelTemplate.find_by_name(label_template_name).id,
		labels: {body: printables.map do |printable|
			{:label => plate_layout(printable)}
		end
	}).save
  end

  def plate_layout(printable_object)
	{
	  :barcode             => printable_object[:barcode],
	  :top_left            => printable_object[:sanger_human_barcode],
	  :bottom_left         => printable_object[:date],
	  :top_right           => printable_object[:collaborator_email],
	  :bottom_right        => printable_object[:uricode],
	  :top_far_right       => printable_object[:number],
	  :bottom_far_right    => "of #{printable_object[:total_number]}",
	  :label_counter_right => "#{printable_object[:num_prints]} prints"
	}  	
  end

  def tube_layout(printable_object)
	{
	  :barcode                 => printable_object[:barcode],
	  :top_line                => printable_object[:sanger_human_barcode],
	  :middle_line             => printable_object[:uricode],
	  :bottom_line             => printable_object[:date],
	  :round_label_top_line    => printable_object[:collaborator_email],
	  :round_label_bottom_line => "(#{printable_object[:number]} of #{printable_object[:total_number]}) #{printable_object[:num_prints]} printed"
	}
  end

end