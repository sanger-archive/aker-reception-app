class Contact < ApplicationRecord
  has_many :material_submissions

  def fullname_and_email
    "#{fullname} <#{email}>"
  end

end
