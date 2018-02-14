require 'rails_helper'

RSpec.describe Contact, type: :model do

  describe '#fullname_and_email' do
    let(:contact) { build(:contact, fullname: "Jeff", email: "jeff@jeff") }
    it "should be correct" do
      expect(contact.fullname_and_email).to eq ("Jeff <jeff@jeff>")
    end
  end

  describe '#fullname' do
    it 'should be sanitised' do
      expect(create(:contact, fullname: '   Alpha   Beta   ').fullname).to eq('Alpha Beta')
    end
  end

  describe '#email' do
    it 'should be sanitised' do
      expect(create(:contact, email: '   USER@EMAIL   ').email).to eq('user@email')
    end
  end

  describe 'validation' do
    it 'should not be valid without a unique sanitised email' do
      create(:contact, email: 'jeff@jeff')
      expect(build(:contact, email: '   JEFF@JEFF  ')).not_to be_valid
    end

    it 'should be valid with a unique sanitised email' do
      create(:contact, email: 'dirk@dirk')
      expect(build(:contact, email: '   JEFF@JEFF  ')).to be_valid
    end
  end

end
