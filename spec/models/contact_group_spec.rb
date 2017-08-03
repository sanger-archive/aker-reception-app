require 'rails_helper'

RSpec.describe ContactGroup, type: :model do
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

end
