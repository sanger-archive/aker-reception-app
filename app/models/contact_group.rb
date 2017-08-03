class ContactGroup < ApplicationRecord
  validates :name, presence: true, uniqueness: true

  def members
    @members ||= LDAPGroupReader.fetch_members(name)
  end
end
