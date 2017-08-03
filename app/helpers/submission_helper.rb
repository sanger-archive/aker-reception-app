module SubmissionHelper
  def available_contacts_select_options
    [['None', '']] + ContactGroup.all_contacts.map { |c| [c.fullname_and_email, c.id] }
  end

  def available_labware_types_select_options
    LabwareType.all.map{|c| ["#{c.name} (#{c.description})", c.id]}
  end

end
