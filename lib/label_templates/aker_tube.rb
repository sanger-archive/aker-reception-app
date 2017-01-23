require './lib/label_template_setup'

# Label template currently defined for sqsc_1dtube_label_template (20/Jan/2017)

def tube_barcode_definition(name, type_id, barcode_type)
  {
    name: name,
    label_type_id: type_id, # Tube
    labels_attributes:[{
      name: 'main_label',
      bitmaps_attributes:[
      	{"horizontal_magnification":"05","vertical_magnification":"05","font":"H","space_adjustment":"03","rotational_angles":"11",
			"x_origin":"0038","y_origin":"0210","field_name":"bottom_line"},
		{"horizontal_magnification":"05","vertical_magnification":"05","font":"H","space_adjustment":"02","rotational_angles":"11",
			"x_origin":"0070","y_origin":"0210","field_name":"middle_line"},
		{"horizontal_magnification":"05","vertical_magnification":"05","font":"H","space_adjustment":"02","rotational_angles":"11",
			"x_origin":"0120","y_origin":"0210","field_name":"top_line"},
		{"horizontal_magnification":"05","vertical_magnification":"1","font":"G","space_adjustment":"00","rotational_angles":"00",
			"x_origin":"0240","y_origin":"0165","field_name":"round_label_top_line"},
		{"horizontal_magnification":"05","vertical_magnification":"1","font":"G","space_adjustment":"00","rotational_angles":"00",
			"x_origin":"0220","y_origin":"0193","field_name":"round_label_bottom_line"}
		],
	  barcodes_attributes:[
        {"barcode_type": barcode_type,"one_module_width":"01","height":"0100","rotational_angle":nil,"one_cell_width":nil,"type_of_check_digit":"2",
        	"no_of_columns":nil,"bar_height":nil,"x_origin":"0043","y_origin":"0100","field_name":"barcode"}
      ]		
	}]
  }
end


LabelTemplateSetup.register_template('aker_ean13_1dtube','Tube') do |name, type_id|
  tube_barcode_definition(name, type_id, "5")
end

LabelTemplateSetup.register_template('aker_code128_1dtube','Tube') do |name, type_id|
  tube_barcode_definition(name, type_id, "9")
end