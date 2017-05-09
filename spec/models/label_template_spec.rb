require 'rails_helper'

RSpec.describe LabelTemplate, type: :model do
  it "can be valid" do
    expect(build(:label_template)).to be_valid
  end
  it "is not valid without a name" do
    expect(build(:label_template, name: nil)).to_not be_valid
  end
  it "is not valid without an external_id" do
    expect(build(:label_template, external_id: nil)).to_not be_valid
  end

  context "when there are other label templates" do
    before do
      @other = create(:label_template, name: 'pie', external_id: 42)
    end

    it "is not valid with a duplicate name" do
      expect(build(:label_template, name: 'pie', external_id: 50)).to_not be_valid
    end

    it "is not valid with a duplicate external_id" do
      expect(build(:label_template, name: 'cake', external_id: 42)).to_not be_valid
    end
    it "is valid without duplicate fields" do
      expect(build(:label_template, name: 'cake', external_id: 50)).to be_valid
    end
  end
end