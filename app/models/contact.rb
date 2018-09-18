class Contact < ApplicationRecord
  has_many :manifests

  before_validation :sanitise_fullname, :sanitise_email
  before_save :sanitise_fullname, :sanitise_email

  validates :email, presence: true, uniqueness: true

  def fullname_and_email
    "#{fullname} <#{email}>"
  end

  def sanitise_fullname
    if fullname
      sanitised = fullname.strip.gsub(/\s+/,' ')
      if sanitised != fullname
        self.fullname = sanitised
      end
    end
  end

  def sanitise_email
    if email
      sanitised = email.strip.downcase
      if sanitised != email
        self.email = sanitised
      end
    end
  end

end
