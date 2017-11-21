require 'rails_helper'
require 'ldap_group_reader'

RSpec.describe ContactGroup, type: :model do

  describe '#name' do
    it 'should be sanitised' do
      expect(create(:contact_group, name: '  ALPHA  ').name).to eq('alpha')
    end
  end

  describe 'validity' do
    it 'can be valid' do
      expect(build(:contact_group)).to be_valid
    end

    it 'should not be valid without a name' do
      expect(build(:contact_group, name: '')).not_to be_valid
    end

    context 'when another group has the same name' do
      let(:other) { create(:contact_group) }

      it { expect(build(:contact_group, name: other.name)).not_to be_valid }
    end

    it 'is not valid without a unique sanitised name' do
      create(:contact_group, name: 'alpha')
      expect(build(:contact_group, name: '  ALPHA  ')).not_to be_valid
    end

    it 'is valid with a unique sanitised name' do
      expect(build(:contact_group, name: '  ALPHA  ')).to be_valid
    end
  end

  describe '#members' do
    let(:group) { build(:contact_group) }
    let(:members) do
      [
        Contact.new(email: 'alpha@omega', fullname: 'Alabama'),
        Contact.new(email: 'beta@psi', fullname: 'Pennsylvester'),
      ]
    end

    before do
      allow(LDAPGroupReader).to receive(:fetch_members).with(group.name).and_return(members)
    end

    it 'should return the members' do
      expect(group.members).to eq(members)
    end
  end

  describe '#all_contacts' do
    let(:groups) { create_list(:contact_group, 2) }
    let(:members_0) do
      [
        Contact.new(email: 'alpha@omega', fullname: 'Alabama'),
        Contact.new(email: 'beta@psi', fullname: 'Pennsylvester'),
      ]
    end
    let(:members_1) do
      [
        Contact.new(email: 'alpha@omega', fullname: 'Alabama'), # repeats a contact from the other group
        Contact.new(email: 'gamma@chi', fullname: 'Colorado'),  # this contact is going to be already created
      ]
    end

    before do
      allow(LDAPGroupReader).to receive(:fetch_members).with(groups.first.name).and_return(members_0)
      allow(LDAPGroupReader).to receive(:fetch_members).with(groups.second.name).and_return(members_1)
      @preexisting_contact = create(:contact, email: members_1[1].email, fullname: 'Connecticut')
      @num_contacts_before = Contact.count
      allow(Rails.configuration).to receive(:fake_ldap).and_return(false)
      @members = ContactGroup.all_contacts
    end

    it 'returns the correct contacts' do
      expected = members_0 + [@preexisting_contact]
      expect(@members.length).to eq(expected.length)
      @members.zip(expected).each do |m,e|
        expect(m.email).to eq(e.email)
        expect(m.fullname).to eq(e.fullname)
        expect(m.id).not_to be_nil
        expect(m.id).to eq(e.id) if e.id
      end
    end

    it 'creates the uncreated contacts' do
      expect(Contact.count).to eq(@num_contacts_before + 2)
    end
  end
end
