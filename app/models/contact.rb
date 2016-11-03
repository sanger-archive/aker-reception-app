class Contact < ApplicationRecord

  def fullname_and_email
    "#{fullname} <#{email}>"
  end

end
