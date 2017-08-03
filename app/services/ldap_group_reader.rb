module LDAPGroupReader
  class << self

    def fetch_members(name)
      member_dns = fetch_member_dns(name)
      fetch_contact_details(member_dns)
    end

  private

    def fetch_member_dns(name)
      group_name_filter = Net::LDAP::Filter.eq('cn', name)
      group_type_filter = Net::LDAP::Filter.eq('objectclass', 'posixGroup')
      filter = group_name_filter & group_type_filter
      attrs = [member_attr]
      group = connection.ldap.search(filter: filter, base: group_base, attributes: attrs).first
      return [] unless group
      group.send(member_attr)
    end

    def fetch_contact_details(dns)
      return [] if dns.empty?
      re = Regexp.new('uid=([^,=]+),' + Regexp.escape(person_base))
      uids = dns.map { |dn| dn.match(re) }.compact.map { |m| m[1] }
      return [] if uids.empty?
      user_filters = uids.map { |uid| Net::LDAP::Filter.eq('uid', uid) }
      filter = user_filters.reduce(:|)
      attrs = ['cn', 'mail']
      results = connection.ldap.search(filter: filter, base: person_base, attributes: attrs)
      results.map { |r| Contact.new(fullname: r.cn.first, email: r.mail.first) }
    end

    def connection
      Devise::LDAP::Adapter.ldap_connect('')
    end

    def person_base
      Rails.application.config.ldap['base']
    end

    def group_base
      Rails.application.config.ldap['group_base']
    end

    def member_attr
      Rails.application.config.ldap['group_membership_attribute']
    end
  end
end