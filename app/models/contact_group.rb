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
    group_contacts = ContactGroup.all.flat_map(&:members).uniq(&:email).map do |contact|
      Contact.create_with(fullname: contact.fullname).find_or_create_by(email: contact.email)
    end
    # There are some groupless contacts that still need adding!
    group_contacts + Contact.all.where.not(email: group_contacts.map(&:email))
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
