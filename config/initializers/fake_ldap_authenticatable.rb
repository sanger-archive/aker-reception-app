require 'devise/strategies/authenticatable'

class FakeLdapAuthenticatable < Devise::Strategies::Authenticatable
  def authenticate!
    return fail(:invalid) if authentication_hash[:email].starts_with? 'x'
    success!(User.find_or_create_by(authentication_hash))
  end
end

Warden::Strategies.add(:fake_ldap_authenticatable, FakeLdapAuthenticatable)