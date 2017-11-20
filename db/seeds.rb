# ABgene AB_0800
LabwareType.create(
  name: 'ABgene AB-0800 shallow well PCR plate',
  description: '0.2ml full skirted clear/colourless 96 well plates (volume <100µl)',
  num_of_cols: 12,
  num_of_rows: 8,
  col_is_alpha: false,
  row_is_alpha: true
)

# ABgene AB_0859
LabwareType.create(
  name: 'ABgene AB-0859 deep well plate',
  description: '0.8ml clear/colourless storage plate (volume > 100µl)',
  num_of_cols: 12,
  num_of_rows: 8,
  col_is_alpha: false,
  row_is_alpha: true
)

# 1.5ml foo bar
LabwareType.create(
  name: 'Eppendorf 2.0ml tube',
  description: 'A tube',
  num_of_cols: 1,
  num_of_rows: 1,
  col_is_alpha: false,
  row_is_alpha: false
)

LabwareType.create(
  name: 'Rack of FluidX 0.75ml tubes',
  description: 'A rack of tubes',
  num_of_cols: 12,
  num_of_rows: 8,
  col_is_alpha: false,
  row_is_alpha: true,
  uses_decapper: true
)

LabwareType.create(
  name: 'Rack of FluidX 0.3ml tubes',
  description: 'A rack of tubes',
  num_of_cols: 12,
  num_of_rows: 8,
  col_is_alpha: false,
  row_is_alpha: true,
  uses_decapper: true
)

Contact.create(
  fullname: Forgery('name').full_name,
  email: Forgery('internet').email_address
)

Contact.create(
  fullname: "Dave",
  email: "dr6@sanger.ac.uk"
)
Contact.create(
  fullname: "Harriet",
  email: "hc6@sanger.ac.uk"
)
Contact.create(
  fullname: "Rich",
  email: "rl15@sanger.ac.uk"
)
Contact.create(
  fullname: "Eduardo",
  email: "emr@sanger.ac.uk"
)
Contact.create(
  fullname: "Chris",
  email: "cs24@sanger.ac.uk"
)
Contact.create(
  fullname: "Phil",
  email: "pj5@sanger.ac.uk"
)

Printer.create(
  name: 'd304bc',
  label_type: 'Plate',
)
Printer.create(
  name: 'f225bc',
  label_type: 'Plate',
)
Printer.create(
  name: 'g216abc',
  label_type: 'Plate',
)
Printer.create(
  name: 'g214bc',
  label_type: 'Plate',
)
Printer.create(
  name: 'e367bc',
  label_type: 'Tube',
)
Printer.create(
  name: 'g216bc',
  label_type: 'Tube',
)
Printer.create(
  name: 'aa313bc',
  label_type: 'Tube',
)
