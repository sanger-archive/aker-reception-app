class Contact < ApplicationRecord
  has_many :material_submissions

  def self.from_user(user)
    find_by_email(user.email)
  end

  def fullname_and_email
    "#{fullname} <#{email}>"
  end

end
