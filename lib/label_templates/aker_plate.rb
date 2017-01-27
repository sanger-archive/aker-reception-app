require './lib/label_template_setup'

# Label template currently defined for sqsc_96plate_label_template (20/Jan/2017)

def bitmap_definition(attrs)
  {"horizontal_magnification":"05",
    "vertical_magnification":"1",
    "font":"G",
    "space_adjustment":"00",
    "rotational_angles":"00"
    }.merge(attrs)
end

def plate_barcode_definition(name, type_id, barcode_type)
  {
    name: name,
    label_type_id: type_id, # Plate
    labels_attributes:[{
      name: 'label',
      bitmaps_attributes:[
        bitmap_definition({"field_name":"top_left","x_origin":"0030","y_origin":"0035"}),
        bitmap_definition({"field_name":"bottom_left","x_origin":"0030","y_origin":"0065"}),
        bitmap_definition({"field_name":"top_right","x_origin":"0550","y_origin":"0035"}),
        bitmap_definition({"field_name":"bottom_right","x_origin":"0550","y_origin":"0065"}),
        bitmap_definition({"field_name":"top_far_right","x_origin":"0750","y_origin":"0035"}),
        bitmap_definition({"field_name":"bottom_far_right","x_origin":"0750","y_origin":"0065"}),
        bitmap_definition({"field_name":"label_counter_right","x_origin":"0890","y_origin":"0065","rotational_angles":"33"})
      ],
      barcodes_attributes:[
        {"field_name":"barcode", "barcode_type": barcode_type,"one_module_width":"02","height":"0070","rotational_angle":nil,"one_cell_width":nil,
          "type_of_check_digit":"2","no_of_columns":nil,"bar_height":nil,"x_origin":"0200","y_origin":"0000",
        }
      ]
    }]
  }  
end

LabelTemplateSetup.register_template('aker_ean13_96plate','Plate') do |name, type_id|
  plate_barcode_definition(name, type_id, "5")
end

LabelTemplateSetup.register_template('aker_code128_96plate','Plate') do |name, type_id|
  plate_barcode_definition(name, type_id, "9")
end