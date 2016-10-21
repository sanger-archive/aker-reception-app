module SubmissionHelper
  def available_contacts_select_options
    [['None', '']].concat(Contact.all.map{|c| ["#{c.fullname} <#{c.email}>", c.email]})
  end

  def available_labware_types_select_options
    LabwareType.all.map{|c| ["#{c.name} (#{c.description})", c.id]}
  end

end
