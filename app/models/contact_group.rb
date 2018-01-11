require 'ldap_group_reader'

class ContactGroup < ApplicationRecord
  validates :name, presence: true, uniqueness: true

  before_validation :sanitise_name
  before_save :sanitise_name

  def members
    @members ||= LDAPGroupReader.fetch_members(name)
  end

  def self.all_contacts
    if Rails.configuration.fake_ldap
      return Contact.all.to_a
    end
    all.flat_map(&:members).uniq(&:email).map do |contact|
      Contact.create_with(fullname: contact.fullname).find_or_create_by(email: contact.email)
    end
  end

  def sanitise_name
    if name
      sanitised = name.strip.downcase
      if sanitised != name
        self.name = sanitised
      end
    end
  end
end
