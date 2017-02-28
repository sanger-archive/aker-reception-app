# ABgene AB_0800
LabwareType.create(
  name: 'ABgene AB_0800',
  description: '0.2ml full skirted clear/colourless 96 well plates (volume <100µl)',
  num_of_cols: 12,
  num_of_rows: 8,
  col_is_alpha: false,
  row_is_alpha: true
)

# ABgene AB_0859
LabwareType.create(
  name: 'ABgene AB_0859',
  description: '0.8ml clear/colourless storage plate (volume > 100µl)',
  num_of_cols: 12,
  num_of_rows: 8,
  col_is_alpha: false,
  row_is_alpha: true
)

# FluidX 0.75
LabwareType.create(
  name: 'FluidX 0.75ml',
  description: '2D barcoded tube rack (volume < 400µl)',
  num_of_cols: 12,
  num_of_rows: 8,
  col_is_alpha: false,
  row_is_alpha: true
)

# 1.5ml foo bar
LabwareType.create(
  name: '1.5ml',
  description: 'foo bar',
  num_of_cols: 1,
  num_of_rows: 1,
  col_is_alpha: false,
  row_is_alpha: false
)

100.times do
  Contact.create(
    fullname: Forgery('name').full_name,
    email: Forgery('internet').email_address
  )
end

Printer.create(
  name: 'd304bc',
  label_type: 'Plate',
)
Printer.create(
  name: 'e367bc',
  label_type: 'Tube',
)
