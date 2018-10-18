require 'rails_helper'
require 'time'

RSpec.describe Manifest, type: :model do

  describe "#active?" do
    context "when the manifest status is active" do
      before do
        @manifest = build(:manifest, status: Manifest.ACTIVE)
      end
      it "should return true" do
        expect(@manifest.active?).to eq(true)
      end
    end

    context "when the manifest status is nil" do
      before do
        @manifest = build(:manifest, status: nil)
      end
      it "should return false" do
        expect(@manifest.active?).to eq(false)
      end
    end

    context "when the manifest status is something else" do
      before do
        @manifest = build(:manifest, status: 'broken')
      end
      it "should return false" do
        expect(@manifest.active?).to eq(false)
      end
    end
  end

  describe "#active_or_labware?" do
    context "when the manifest status is active" do
      before do
        @manifest = build(:manifest, status: Manifest.ACTIVE)
      end
      it "should return true" do
        expect(@manifest.active_or_labware?).to eq(true)
      end
    end

    context "when the manifest status is nil" do
      before do
        @manifest = build(:manifest, status: nil)
      end
      it "should return false" do
        expect(@manifest.active_or_labware?).to eq(false)
      end
    end

    context "when the manifest status is labware" do
      before do
        @manifest = build(:manifest, status: 'labware')
      end
      it "should return true" do
        expect(@manifest.active_or_labware?).to eq(true)
      end
    end

    context "when the manifest status is something else" do
      before do
        @manifest = build(:manifest, status: 'broken')
      end
      it "should return false" do
        expect(@manifest.active_or_labware?).to eq(false)
      end
    end
  end

  describe "#active_or_provenance?" do
    context "when the manifest status is active" do
      before do
        @manifest = build(:manifest, status: Manifest.ACTIVE)
      end
      it "should return true" do
        expect(@manifest.active_or_provenance?).to eq(true)
      end
    end

    context "when the manifest status is nil" do
      before do
        @manifest = build(:manifest, status: nil)
      end
      it "should return false" do
        expect(@manifest.active_or_provenance?).to eq(false)
      end
    end

    context "when the manifest status is provenance" do
      before do
        @manifest = build(:manifest, status: 'provenance')
      end
      it "should return true" do
        expect(@manifest.active_or_provenance?).to eq(true)
      end
    end

    context "when the manifest status is something else" do
      before do
        @manifest = build(:manifest, status: 'broken')
      end
      it "should return false" do
        expect(@manifest.active_or_provenance?).to eq(false)
      end
    end
  end

  describe "#active_or_dispatch?" do
    context "when the manifest status is active" do
      before do
        @manifest = build(:manifest, status: Manifest.ACTIVE)
      end
      it "should return true" do
        expect(@manifest.active_or_dispatch?).to eq(true)
      end
    end

    context "when the manifest status is nil" do
      before do
        @manifest = build(:manifest, status: nil)
      end
      it "should return false" do
        expect(@manifest.active_or_dispatch?).to eq(false)
      end
    end

    context "when the manifest status is dispatch" do
      before do
        @manifest = build(:manifest, status: 'dispatch')
      end
      it "should return true" do
        expect(@manifest.active_or_dispatch?).to eq(true)
      end
    end

    context "when the manifest status is something else" do
      before do
        @manifest = build(:manifest, status: 'broken')
      end
      it "should return false" do
        expect(@manifest.active_or_dispatch?).to eq(false)
      end
    end
  end

  describe "#active_or_printed?" do
    context "when the manifest status is active" do
      before do
        @manifest = build(:manifest, status: Manifest.ACTIVE)
      end
      it "should return true" do
        expect(@manifest.active_or_printed?).to eq(true)
      end
    end

    context "when the manifest status is nil" do
      before do
        @manifest = build(:manifest, status: nil)
      end
      it "should return false" do
        expect(@manifest.active_or_printed?).to eq(false)
      end
    end

    context "when the manifest status is printed" do
      before do
        @manifest = build(:manifest, status: Manifest.PRINTED)
      end
      it "should return true" do
        expect(@manifest.active_or_printed?).to eq(true)
      end
    end

    context "when the manifest status is something else" do
      before do
        @manifest = build(:manifest, status: 'broken')
      end
      it "should return false" do
        expect(@manifest.active_or_printed?).to eq(false)
      end
    end
  end


  describe "#pending?" do
    context "when the manifest status is non-pending" do
      before do
        statuses = [Manifest.ACTIVE, Manifest.PRINTED, Manifest.BROKEN]
        @manifests = statuses.map { |s| build(:manifest, status: s )}
      end
      it "should return false" do
        @manifests.each { |s| expect(s.pending?).to eq(false) }
      end
    end

    context "when the manifest status is pending" do
      before do
        statuses = [nil, 'labware', 'provenance', 'dispatch']
        @manifests = statuses.map { |s| build(:manifest, status: s )}
      end
      it "should return true" do
        @manifests.each { |s| expect(s.pending?).to eq(true) }
      end
    end
  end

  describe "#broken" do
    before do
      @manifest = build(:manifest, status: 'labware')
    end

    it "should work properly" do
      expect(@manifest.broken?).to eq(false)
      @manifest.broken!
      expect(@manifest.broken?).to eq(true)
      expect(Manifest.find(@manifest.id).broken?).to eq(true)
    end
  end

  describe "#create_labware" do
    before do
      @manifest = create(:manifest,
        labware_type: create(:labware_type),
        supply_labwares: true,
        contact: create(:contact),
        address: 'Space',
      )
      @manifest.no_of_labwares_required = 2
      @manifest.save!
      @manifest.reload
      @old_labware = @manifest.labwares.pluck(:id)
    end

    context "when no_of_labwares_required is altered" do
      before do
        @manifest.no_of_labwares_required = 3
        @manifest.save!
        @manifest.reload
      end

      it "destroys the old labware" do
        @old_labware.each do |lwid|
          expect(Labware.where(id: lwid)).to be_empty
        end
      end

      it "creates new labware" do
        expect(@manifest.labwares.length).to eq 3
        @manifest.labwares.each do |lw|
          expect(lw).not_to be_nil
          expect(Labware.find(lw.id)).to eq(lw)
        end
      end
    end

    context "when labware type is altered" do
      before do
        @manifest.labware_type = create(:labware_type, num_of_rows: 7)
        @manifest.save!
        @manifest.reload
      end

      it "destroys the old labware" do
        @old_labware.each do |lwid|
          expect(Labware.where(id: lwid)).to be_empty
        end
      end

      it "creates new labware" do
        expect(@manifest.labwares.length).to eq 2
        @manifest.labwares.each do |lw|
          expect(lw).not_to be_nil
          expect(Labware.find(lw.id)).to eq(lw)
        end
      end
    end
  end

  describe "#each_labware_has_contents" do
    before do
      @manifest = create(:manifest,
        labware_type: create(:labware_type),
        supply_labwares: true,
        contact: create(:contact),
        address: 'Space',
      )
      @manifest.no_of_labwares_required = 2
      @manifest.save!
      @manifest.reload
    end

    context "when every labware has contents" do
      before do
        @manifest.labwares.each do |lw|
          lw.update_attributes(contents: {"1" => { "gender" => "female" }, "2" => { "gender" => "male" }})
        end
      end

      it "active save should return true" do
        @manifest.status = Manifest.ACTIVE
        expect(@manifest.save).to eq(true)
      end

      it "the total sample size should reflect the number of samples not the size of the labware" do
        expect(@manifest.total_samples).to eq(2 * 2)
        expect(@manifest.total_samples).not_to eq(@manifest.labwares.sum(&:size))
      end
    end

    context "when not every labware has contents" do
      before do
        @manifest.labwares[0].update_attributes(contents: {"1" => { "gender" => "male" }})
      end

      it "save on last step (dispatch) should return false" do
        @manifest.update(last_step: true)
        expect(@manifest.save).to eq(false)
      end
    end

    context "when none of the labware has contents on the last step of the process (dispatch)" do
      it "active save should return false" do
        @manifest.update(last_step: true)
        expect(@manifest.save).to eq(false)
      end
    end
  end

  describe "#any_human_material?" do
    context "when there is no labware" do
      before do
        @manifest = create(:manifest)
      end
      it "has no human material" do
        expect(@manifest).not_to be_any_human_material
      end
    end
    context "when there is labware with no human material" do
      before do
        @manifest = create(:manifest)
        @labware = create(:labware, manifest: @manifest)
      end
      it "has no human material" do
        expect(@manifest.labwares).not_to be_empty
        expect(@manifest).not_to be_any_human_material
      end
    end
    context "when there is labware with human material" do
      before do
        @manifest = create(:manifest)
        @labware = create(:labware, manifest: @manifest, contents: { "1" => { 'scientific_name' => 'Homo Sapiens'}})
      end
      it "has human material" do
        expect(@manifest).to be_any_human_material
      end
    end
  end

  describe "#ethical?" do
    context "when there is ethical labware with human material" do
      before do
        @manifest = create(:manifest)
        @labware = create(:labware, manifest: @manifest, contents: { "1" => {'scientific_name' => 'Homo Sapiens', 'hmdmc' => '12/345', 'hmdmc_set_by' => 'dirk'}})
      end
      it "is ethical" do
        expect(@manifest.labwares).not_to be_empty
        expect(@manifest).to be_ethical
      end
    end
    context "when there is labware missing ethics" do
      before do
        @manifest = create(:manifest)
        @labware = create(:labware, manifest: @manifest, contents: { "1" => {'scientific_name' => 'Homo Sapiens' }})
      end
      it "is not ethical" do
        expect(@manifest).not_to be_ethical
      end
    end
  end

  describe "#set_hmdmc_not_required" do
    before do
      @manifest = create(:manifest)
      @labware = create(:labware, manifest: @manifest, contents: { "1" => {'scientific_name' => 'Homo Sapiens' }})
    end
    it "sets the not-required on the labware" do
      @manifest.set_hmdmc_not_required('dirk')
      expect(@manifest.labwares.first.contents).to eq({ "1" => {'scientific_name' => 'Homo Sapiens', 'hmdmc_not_required_confirmed_by' => 'dirk' }})
    end
  end

  describe "#clear_hmdmc" do
    before do
      @manifest = create(:manifest)
      @labware = create(:labware, manifest: @manifest, contents: { "1" => {'scientific_name' => 'Homo Sapiens', 'hmdmc' => '12/345' }})
    end
    it "clears hmdmc information from the labware" do
      @manifest.clear_hmdmc
      expect(@manifest.labwares.first.contents).to eq({ "1" => {'scientific_name' => 'Homo Sapiens' }})
    end
  end

  describe "#first_hmdmc" do
    context "when there is no labware" do
      before do
        @manifest = create(:manifest)
      end
      it "returns nil" do
        expect(@manifest.first_hmdmc).to be_nil
      end
    end
    context "when the labware has an hmdmc" do
      before do
        @manifest = create(:manifest)
        @labware = create(:labware, manifest: @manifest, contents: { "1" => {'scientific_name' => 'Homo Sapiens', 'hmdmc' => '12/345' }})
      end
      it "returns the hmdmc" do
        expect(@manifest.first_hmdmc).to eq('12/345')
      end
    end
    context "when the labware has no hmdmc" do
      before do
        @manifest = create(:manifest)
        @labware = create(:labware, manifest: @manifest, contents: { "1" => {'scientific_name' => 'Homo Sapiens' }})
      end
      it "returns nil" do
        expect(@manifest.first_hmdmc).to be_nil
      end
    end
  end

  describe "#confirmed_no_hmdmc" do
    context "when there is no labware" do
      before do
        @manifest = create(:manifest)
      end
      it "is not confirmed_no_hmdmc" do
        expect(@manifest).not_to be_confirmed_no_hmdmc
      end
    end
    context "when the labware has a hmdmc_not_required_confirmed_by" do
      before do
        @manifest = create(:manifest)
        @labware = create(:labware, manifest: @manifest, contents: { "1" => {'scientific_name' => 'Homo Sapiens', 'hmdmc_not_required_confirmed_by' => 'dirk' }})
      end
      it "is confirmed_no_hmdmc" do
        expect(@manifest).to be_confirmed_no_hmdmc
      end
    end
    context "when the labware has no hmdmc_not_required_confirmed_by" do
      before do
        @manifest = create(:manifest)
        @labware = create(:labware, manifest: @manifest, contents: { "1" => {'scientific_name' => 'Homo Sapiens' }})
      end
      it "is not confirmed_no_hmdmc" do
        expect(@manifest).not_to be_confirmed_no_hmdmc
      end
    end
  end

  describe '#supply_decappers' do
    # supply_decappers cannot be true unless the labware type supports it, and supply_labwares is true.

    let(:uses_decappers) { true }
    let(:supply_labwares) { true }
    let(:supply_decappers) { true }
    let(:labware_type) { create(uses_decappers ? :rack_labware_type : :labware_type) }
    let(:manifest) { create(:manifest, labware_type: labware_type, supply_labwares: supply_labwares, supply_decappers: supply_decappers) }

    context "when the labware type does not use decappers" do
      let(:uses_decappers) { false }
      it { expect(manifest.supply_decappers).to eq(false) }
    end

    context "when supply labwares is false" do
      let(:supply_labwares) { false }
      it { expect(manifest.supply_decappers).to eq(false) }
    end

    context "when supply decappers is false" do
      let(:supply_decappers) { false }
      it { expect(manifest.supply_decappers).to eq(false) }
    end

    context "when the labware type uses decappers, supply labwares is true, and supply decappers is true" do
      it { expect(manifest.supply_decappers).to eq(true) }
    end
  end

  describe '#owner_email' do
    it 'should be sanitised' do
      expect(create(:manifest, owner_email: '   USER@EMAIL  ').owner_email).to eq('user@email')
    end
  end

  describe 'labware' do
    it "shouldn't allow a value greater than 10" do
      expect(build(:manifest, status: 'labware', supply_labwares: false, no_of_labwares_required: 11)).to_not be_valid
    end

    it "shouldn't allow a value less than 1" do
      expect(build(:manifest, status: 'labware', supply_labwares: false, no_of_labwares_required: -2)).to_not be_valid
    end
  end

  describe '#dispatched?' do

    context 'when dispatch_date is set' do
      it 'is true' do
        expect(build(:printed_manifest, dispatch_date: Time.now).dispatched?).to be true
      end
    end

    context 'when dispatch_date is nil' do
      it 'is false' do
        expect(build(:printed_manifest).dispatched?).to be false
      end
    end

  end

  describe 'dispatch_date validation' do

    context 'when status is not "printed"' do

      it 'does not allow changing "dispatch_date"' do
        expect(build(:active_manifest, dispatch_date: Time.now)).to_not be_valid
      end

    end

    context 'when status is "printed"' do

      it 'does allow changing "dispatch_date"' do
        expect(build(:printed_manifest, dispatch_date: Time.now)).to be_valid
      end
    end

  end

  describe '#dispatch!' do

    context 'when status is "printed"' do

      before do
        @manifest = create(:printed_manifest)
      end

      it 'sets the dispatch_date' do
        expect { @manifest.dispatch! }.to change { @manifest.dispatch_date }
      end

    end

    context 'when status is not "printed"' do

      before do
        @manifest = create(:active_manifest)
      end

      it 'raises an Error' do
        expect { @manifest.dispatch! }.to raise_error ActiveRecord::RecordInvalid
      end

    end

  end

end
