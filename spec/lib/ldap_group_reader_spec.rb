require 'rails_helper'
require 'ldap_group_reader'

RSpec.describe LDAPGroupReader do
  let(:ldap) { instance_double(Net::LDAP) }
  let(:connection) { instance_double(Devise::LDAP::Connection, ldap: ldap) }
  let(:group_base) { 'ou=group,dc=sanger,dc=ac,dc=uk' }
  let(:person_base) { 'ou=people,dc=sanger,dc=ac,dc=uk' }
  let(:member_attr) { 'member' }
  let(:ldap_config) do
    {
      'base' => person_base,
      'group_base' => group_base,
      'group_membership_attribute' => member_attr,
    }
  end

  before do
    allow(Devise::LDAP::Adapter).to receive(:ldap_connect).and_return(connection)
    allow(Rails.application.config).to receive(:ldap).and_return(ldap_config)
  end

  describe '#fetch_members' do
    let(:group_name) { 'mygroup' }
    let(:group_filter) {
      Net::LDAP::Filter.eq('cn', group_name) & Net::LDAP::Filter.eq('objectclass', 'posixGroup')
    }

    context 'when the group does not exist' do
      before do
        allow(ldap).to receive(:search).
          with(filter: group_filter, base: group_base, attributes: [member_attr]).
          and_return([])
      end

      it 'should return an empty array' do
        expect(LDAPGroupReader.fetch_members(group_name)).to be_empty
      end
    end

    context 'when the group exists' do
      let(:ldap_group) do
        lg = double('ldap-group')
        allow(lg).to receive(member_attr).and_return(ldap_group_members)
        lg
      end

      before do
        allow(ldap).to receive(:search).
          with(filter: group_filter, base: group_base, attributes: [member_attr]).
          and_return([ldap_group])
      end

      context 'when the group has no members' do
        let(:ldap_group_members) { [] }

        it 'should return an empty array' do
          expect(LDAPGroupReader.fetch_members(group_name)).to be_empty
        end
      end


      context 'when the group has members' do
        let(:member_uids) { ['alpha', 'beta', 'gamma'] }
        let(:ldap_group_members) { member_uids.map { |uid| "uid=#{uid},#{person_base}" } }

        let(:ldap_people) do
          member_uids.map { |uid| double('ldap-person', cn: ["#{uid} mc#{uid}"], mail: ["#{uid}@place.com"]) }
        end

        let(:person_filter) {
          Net::LDAP::Filter.eq('uid', 'alpha') | Net::LDAP::Filter.eq('uid', 'beta') | Net::LDAP::Filter.eq('uid', 'gamma')
        }

        before do
          allow(ldap).to receive(:search).
            with(filter: person_filter, base: person_base, attributes: ['cn', 'mail']).
            and_return(ldap_people)
        end

        it 'should return correct contacts' do
          result = LDAPGroupReader.fetch_members(group_name)
          expect(result.length).to eq(ldap_people.length)
          result.zip(ldap_people).each do |r, e|
            expect(r.fullname).to eq(e.cn.first)
            expect(r.email).to eq(e.mail.first)
          end
        end
      end
    end
  end
end
