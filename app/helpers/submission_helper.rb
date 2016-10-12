module SubmissionHelper
  def available_contacts_select_options
    [['None', '']].concat(Contact.all.map{|c| ["#{c.fullname} <#{c.email}>", c.email]})
  end
end
