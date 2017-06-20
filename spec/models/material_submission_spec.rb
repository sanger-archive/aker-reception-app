require 'rails_helper'

RSpec.describe MaterialSubmission, type: :model do

  describe "#active?" do
    context "when the submission status is active" do
      before do
        @submission = build(:material_submission, status: MaterialSubmission.ACTIVE)
      end
      it "should return true" do
        expect(@submission.active?).to eq(true)
      end
    end

    context "when the submission status is nil" do
      before do
        @submission = build(:material_submission, status: nil)
      end
      it "should return false" do
        expect(@submission.active?).to eq(false)
      end
    end

    context "when the submission status is something else" do
      before do
        @submission = build(:material_submission, status: 'broken')
      end
      it "should return false" do
        expect(@submission.active?).to eq(false)
      end
    end
  end

  describe "#claimed?" do
    context "when the submission status is active" do
      before do
        @submission = build(:material_submission, status: MaterialSubmission.ACTIVE)
      end
      it "should return false" do
        expect(@submission.claimed?).to eq(false)
      end
    end

    context "when the submission status is nil" do
      before do
        @submission = build(:material_submission, status: nil)
      end
      it "should return false" do
        expect(@submission.claimed?).to eq(false)
      end
    end

    context "when the submission status is claimed" do
      before do
        @submission = build(:material_submission, status: MaterialSubmission.CLAIMED)
      end
      it "should return true" do
        expect(@submission.claimed?).to eq(true)
      end
    end

    context "when the submission status is something else" do
      before do
        @submission = build(:material_submission, status: 'broken')
      end
      it "should return false" do
        expect(@submission.claimed?).to eq(false)
      end
    end
  end

  describe "#pending?" do
    context "when the submission status is non-pending" do
      before do
        statuses = [MaterialSubmission.ACTIVE, MaterialSubmission.AWAITING, MaterialSubmission.CLAIMED, MaterialSubmission.BROKEN]
        @submissions = statuses.map { |s| build(:material_submission, status: s )}
      end
      it "should return false" do
        @submissions.each { |s| expect(s.pending?).to eq(false) }
      end
    end

    context "when the submission status is pending" do
      before do
        statuses = [nil, 'labware', 'provenance', 'dispatch']
        @submissions = statuses.map { |s| build(:material_submission, status: s )}
      end
      it "should return true" do
        @submissions.each { |s| expect(s.pending?).to eq(true) }
      end
    end
  end

  describe "#broken" do
    before do
      @submission = build(:material_submission, status: 'labware')
    end

    it "should work properly" do
      expect(@submission.broken?).to eq(false)
      @submission.broken!
      expect(@submission.broken?).to eq(true)
      expect(MaterialSubmission.find(@submission.id).broken?).to eq(true)
    end
  end

  describe "#ready_for_claim?" do
    before do
      @submission = create(:material_submission,
        labware_type: create(:labware_type),
        supply_labwares: true,
      #  no_of_labwares_required: 2,
        contact: create(:contact),
        address: 'Space',
      )
      @submission.no_of_labwares_required = 2
      @submission.save!
      @submission.reload
      @submission.labwares.each do |lw|
        lw.update_attributes(barcode: "AKER-#{lw.id}", print_count: 1)
      end
    end
    context "when status is not 'awaiting'" do
      before do
        @submission.labwares.each do |lw|
          create(:material_reception, labware_id: lw.id)
        end
      end
      it "returns false" do
        expect(@submission.ready_for_claim?).to eq(false)
      end
    end

    context "when not all labware are received" do
      before do
        @submission.update_attributes(status: MaterialSubmission.AWAITING)
        create(:material_reception, labware_id: @submission.labwares.first.id)
      end
      it "returns false" do
        expect(@submission.ready_for_claim?).to eq(false)
      end
    end

    context "when status is 'awaiting' and all labware are received" do
      before do
        @submission.labwares.each do |lw|
          create(:material_reception, labware_id: lw.id)
        end
        @submission.update_attributes(status: MaterialSubmission.AWAITING)
      end
      it "returns true" do
        expect(@submission.ready_for_claim?).to eq(true)
      end
    end
  end

  describe "#create_labware" do
    before do
      @submission = create(:material_submission,
        labware_type: create(:labware_type),
        supply_labwares: true,
      #  no_of_labwares_required: 2,
        contact: create(:contact),
        address: 'Space',
      )
      @submission.no_of_labwares_required = 2
      @submission.save!
      @submission.reload
      @old_labware = @submission.labwares.pluck(:id)
    end

    context "when no_of_labwares_required is altered" do
      before do
        @submission.no_of_labwares_required = 3
        @submission.save!
        @submission.reload
      end

      it "destroys the old labware" do
        @old_labware.each do |lwid|
          expect(Labware.where(id: lwid)).to be_empty
        end
      end

      it "creates new labware" do
        expect(@submission.labwares.length).to eq 3
        @submission.labwares.each do |lw|
          expect(lw).not_to be_nil
          expect(Labware.find(lw.id)).to eq(lw)
        end
      end
    end

    context "when labware type is altered" do
      before do
        @submission.labware_type = create(:labware_type, num_of_rows: 7)
        @submission.save!
        @submission.reload
      end

      it "destroys the old labware" do
        @old_labware.each do |lwid|
          expect(Labware.where(id: lwid)).to be_empty
        end
      end

      it "creates new labware" do
        expect(@submission.labwares.length).to eq 2
        @submission.labwares.each do |lw|
          expect(lw).not_to be_nil
          expect(Labware.find(lw.id)).to eq(lw)
        end
      end
    end
  end

  describe "#each_labware_has_contents" do
    before do
      @submission = create(:material_submission,
        labware_type: create(:labware_type),
        supply_labwares: true,
      #  no_of_labwares_required: 2,
        contact: create(:contact),
        address: 'Space',
      )
      @submission.no_of_labwares_required = 2
      @submission.save!
      @submission.reload
    end

    context "when every labware has contents" do
      before do
        @submission.labwares.each do |lw|
          lw.update_attributes(contents: {"1" => { "gender" => "female" }})
        end
      end

      it "active save should return true" do
        @submission.status = MaterialSubmission.ACTIVE
        expect(@submission.save).to eq(true)
      end
    end

    context "when not every labware has contents" do
      before do
        @submission.labwares[0].update_attributes(contents: {"1" => { "gender" => "male" }})
      end

      it "active save should return false" do
        @submission.status = MaterialSubmission.ACTIVE
        expect(@submission.save).to eq(false)
      end
    end

    context "when none of the labware has contents" do
      it "active save should return false" do
        @submission.status = MaterialSubmission.ACTIVE
        expect(@submission.save).to eq(false)
      end
    end
  end

  describe "#any_human_material?" do
    context "when there is no labware" do
      before do
        @submission = create(:material_submission)
      end
      it "has no human material" do
        expect(@submission).not_to be_any_human_material
      end
    end
    context "when there is labware with no human material" do
      before do
        @submission = create(:material_submission)
        @labware = create(:labware, material_submission: @submission)
      end
      it "has no human material" do
        expect(@submission.labwares).not_to be_empty
        expect(@submission).not_to be_any_human_material
      end
    end
    context "when there is labware with human material" do
      before do
        @submission = create(:material_submission)
        @labware = create(:labware, material_submission: @submission, contents: { "1" => { 'common_name' => 'Homo Sapiens'}})
      end
      it "has human material" do
        expect(@submission).to be_any_human_material
      end
    end
  end

  describe "#ethical?" do
    context "when there is ethical labware with human material" do
      before do
        @submission = create(:material_submission)
        @labware = create(:labware, material_submission: @submission, contents: { "1" => {'common_name' => 'Homo Sapiens', 'hmdmc' => '12/345', 'hmdmc_set_by' => 'dirk'}})
      end
      it "is ethical" do
        expect(@submission.labwares).not_to be_empty
        expect(@submission).to be_ethical
      end
    end
    context "when there is labware missing ethics" do
      before do
        @submission = create(:material_submission)
        @labware = create(:labware, material_submission: @submission, contents: { "1" => {'common_name' => 'Homo Sapiens' }})
      end
      it "is not ethical" do
        expect(@submission).not_to be_ethical
      end
    end
  end

  describe "#set_hmdmc" do
    before do
      @submission = create(:material_submission)
      @labware = create(:labware, material_submission: @submission, contents: { "1" => {'common_name' => 'Homo Sapiens' }})
    end
    it "sets the hmdmc on the labware" do
      @submission.set_hmdmc('12/345', 'dirk')
      expect(@submission.labwares.first.contents).to eq({ "1" => {'common_name' => 'Homo Sapiens', 'hmdmc' => '12/345', 'hmdmc_set_by' => 'dirk' }})
    end
  end

  describe "#set_hmdmc_not_required" do
    before do
      @submission = create(:material_submission)
      @labware = create(:labware, material_submission: @submission, contents: { "1" => {'common_name' => 'Homo Sapiens' }})
    end
    it "sets the not-required on the labware" do
      @submission.set_hmdmc_not_required('dirk')
      expect(@submission.labwares.first.contents).to eq({ "1" => {'common_name' => 'Homo Sapiens', 'hmdmc_not_required_confirmed_by' => 'dirk' }})
    end
  end

  describe "#clear_hmdmc" do
    before do
      @submission = create(:material_submission)
      @labware = create(:labware, material_submission: @submission, contents: { "1" => {'common_name' => 'Homo Sapiens', 'hmdmc' => '12/345' }})
    end
    it "clears hmdmc information from the labware" do
      @submission.clear_hmdmc
      expect(@submission.labwares.first.contents).to eq({ "1" => {'common_name' => 'Homo Sapiens' }})
    end
  end

  describe "#first_hmdmc" do
    context "when there is no labware" do
      before do
        @submission = create(:material_submission)
      end
      it "returns nil" do
        expect(@submission.first_hmdmc).to be_nil
      end
    end
    context "when the labware has an hmdmc" do
      before do
        @submission = create(:material_submission)
        @labware = create(:labware, material_submission: @submission, contents: { "1" => {'common_name' => 'Homo Sapiens', 'hmdmc' => '12/345' }})
      end
      it "returns the hmdmc" do
        expect(@submission.first_hmdmc).to eq('12/345')
      end
    end
    context "when the labware has no hmdmc" do
      before do
        @submission = create(:material_submission)
        @labware = create(:labware, material_submission: @submission, contents: { "1" => {'common_name' => 'Homo Sapiens' }})
      end
      it "returns nil" do
        expect(@submission.first_hmdmc).to be_nil
      end
    end
  end

  describe "#confirmed_no_hmdmc" do
    context "when there is no labware" do
      before do
        @submission = create(:material_submission)
      end
      it "is not confirmed_no_hmdmc" do
        expect(@submission).not_to be_confirmed_no_hmdmc
      end
    end
    context "when the labware has a hmdmc_not_required_confirmed_by" do
      before do
        @submission = create(:material_submission)
        @labware = create(:labware, material_submission: @submission, contents: { "1" => {'common_name' => 'Homo Sapiens', 'hmdmc_not_required_confirmed_by' => 'dirk' }})
      end
      it "is confirmed_no_hmdmc" do
        expect(@submission).to be_confirmed_no_hmdmc
      end
    end
    context "when the labware has no hmdmc_not_required_confirmed_by" do
      before do
        @submission = create(:material_submission)
        @labware = create(:labware, material_submission: @submission, contents: { "1" => {'common_name' => 'Homo Sapiens' }})
      end
      it "is not confirmed_no_hmdmc" do
        expect(@submission).not_to be_confirmed_no_hmdmc
      end
    end
  end

end
