module LDAPGroupReader
  class << self

    def fetch_members(name, options={})
      options = {active_people_only: true}.merge(options)
      connection = make_connection
      member_dns = fetch_member_dns(connection, name)
      fetch_contact_details(connection, member_dns, options)
    end

  private

    def fetch_member_dns(connection, name)
      group_name_filter = Net::LDAP::Filter.eq('cn', name)
      group_type_filter = Net::LDAP::Filter.eq('objectclass', 'posixGroup')
      filter = group_name_filter & group_type_filter
      attrs = [member_attr]
      group = connection.ldap.search(filter: filter, base: group_base, attributes: attrs).first
      return [] unless group
      group.send(member_attr)
    end

    def fetch_contact_details(connection, dns, options)
      return [] if dns.empty?
      # These DNs should look like "uid=XXX," followed by the content of person_base.
      # Use a regular expression to check the format and extract the uid
      re = Regexp.new('uid=([^,=]+),' + Regexp.escape(person_base))
      uids = dns.map { |dn| dn.match(re) }.compact.map { |m| m[1] }
      return [] if uids.empty?
      user_filters = uids.map { |uid| Net::LDAP::Filter.eq('uid', uid) }
      filter = user_filters.reduce(:|)
      if options[:active_people_only]
        filter &= active_people_filter
      end
      attrs = ['cn', 'mail']
      results = connection.ldap.search(filter: filter, base: person_base, attributes: attrs)
      results.map { |r| Contact.new(fullname: r.cn.first, email: r.mail.first) }
    end

    def active_people_filter
      # All these fields and values are basically magic.
      Net::LDAP::Filter.eq('sangerActiveAccount', :TRUE) &
        Net::LDAP::Filter.eq('sangerRealPerson', :TRUE) &
        Net::LDAP::Filter.ne('sangerEmployeeStatus', 99)
    end

    def make_connection
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