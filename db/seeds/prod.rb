# frozen_string_literal: true

labware_types = [
  {
    name: 'ABgene AB-0800 shallow well PCR plate',
    description: '0.2ml full skirted clear/colourless 96 well plates (volume <100µl)',
    num_of_cols: 12,
    num_of_rows: 8,
    col_is_alpha: false,
    row_is_alpha: true,
  },
  {
    name: 'ABgene AB-0859 deep well plate',
    description: '0.8ml clear/colourless storage plate (volume > 100µl)',
    num_of_cols: 12,
    num_of_rows: 8,
    col_is_alpha: false,
    row_is_alpha: true,
  },
  {
    name: 'Eppendorf 2.0ml tube',
    description: 'A tube',
    num_of_cols: 1,
    num_of_rows: 1,
    col_is_alpha: false,
    row_is_alpha: false,
  },
  {
    name: 'Rack of FluidX 0.75ml tubes',
    description: 'A rack of tubes',
    num_of_cols: 12,
    num_of_rows: 8,
    col_is_alpha: false,
    row_is_alpha: true,
    uses_decapper: true,
  },
  {
    name: 'Rack of FluidX 0.3ml tubes',
    description: 'A rack of tubes',
    num_of_cols: 12,
    num_of_rows: 8,
    col_is_alpha: false,
    row_is_alpha: true,
    uses_decapper: true,
  },
]

labware_types.each do |args|
  unless LabwareType.find_by(name: args[:name])
    LabwareType.create!(args)
  end
end

printers = [
  {
    name: 'd304bc',
    label_type: 'Plate',
  },
  {
    name: 'f225bc',
    label_type: 'Plate',
  },
  {
    name: 'g216abc',
    label_type: 'Plate',
  },
  {
    name: 'g214bc',
    label_type: 'Plate',
  },
  {
    name: 'e367bc',
    label_type: 'Tube',
  },
  {
    name: 'g216bc',
    label_type: 'Tube',
  },
  {
    name: 'aa313bc',
    label_type: 'Tube',
  },
]

printers.each do |args|
  unless Printer.find_by(name: args[:name])
    Printer.create(args)
  end
end

['sample_guardians'].each do |name|
  unless ContactGroup.find_by(name: name)
    ContactGroup.create(name: name)
  end
end
