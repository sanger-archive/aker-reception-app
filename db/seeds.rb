# ABgene AB_0800
LabwareType.create(
  name: 'ABgene AB_0800',
  description: '0.2ml full skirted clear/colourless 96 well plates (volume <100µl)',
  x_dimension_size: 12,
  y_dimension_size: 8,
  x_dimension_is_alpha: false,
  y_dimension_is_alpha: true
)

# ABgene AB_0859
LabwareType.create(
  name: 'ABgene AB_0859',
  description: '0.8ml clear/colourless storage plate (volume > 100µl)',
  x_dimension_size: 12,
  y_dimension_size: 8,
  x_dimension_is_alpha: false,
  y_dimension_is_alpha: true
)

# FluidX 0.75
LabwareType.create(
  name: 'FluidX 0.75ml',
  description: '2D barcoded tube rack (volume < 400µl)',
  x_dimension_size: 12,
  y_dimension_size: 8,
  x_dimension_is_alpha: false,
  y_dimension_is_alpha: true
)

# 1.5ml foo bar
LabwareType.create(
  name: '1.5ml',
  description: 'foo bar',
  x_dimension_size: 1,
  y_dimension_size: 1,
  x_dimension_is_alpha: false,
  y_dimension_is_alpha: false
)

100.times do
  Contact.create(
    fullname: Forgery('name').full_name,
    email: Forgery('internet').email_address
  )
end
