require 'rails_helper'

RSpec.describe MaterialSubmission, type: :model do
  describe "testing status" do
    @tests_status = {
      MaterialSubmission.ACTIVE => [
        { message: :active?, value: true},
        { message: :active_or_labware?, value: true},
        { message: :active_or_provenance?, value: true},
        { message: :active_or_dispatch?, value: true},
        { message: :active_or_awaiting?, value: true},
        { message: :pending?, value: false},
        { message: :broken?, value: false},
        { message: :claimed?, value: false},
        { message: :ready_for_claim?, value: false}
      ],
      MaterialSubmission.AWAITING => [
        { message: :active?, value: false},
        { message: :active_or_labware?, value: false},
        { message: :active_or_provenance?, value: false},
        { message: :active_or_dispatch?, value: false},
        { message: :active_or_awaiting?, value: true},
        { message: :pending?, value: false},
        { message: :broken?, value: false},
        { message: :claimed?, value: false},
        { message: :ready_for_claim?, value: true}  # With an empty group of labwares
      ],
      MaterialSubmission.CLAIMED => [
        { message: :active?, value: false},
        { message: :active_or_labware?, value: false},
        { message: :active_or_provenance?, value: false},
        { message: :active_or_dispatch?, value: false},
        { message: :active_or_awaiting?, value: false},
        { message: :pending?, value: false},
        { message: :broken?, value: false},
        { message: :claimed?, value: true},
        { message: :ready_for_claim?, value: false}
      ],
      MaterialSubmission.BROKEN => [
        { message: :active?, value: false},
        { message: :active_or_labware?, value: false},
        { message: :active_or_provenance?, value: false},
        { message: :active_or_dispatch?, value: false},
        { message: :active_or_awaiting?, value: false},
        { message: :pending?, value: false},
        { message: :broken?, value: true},
        { message: :claimed?, value: false},
        { message: :ready_for_claim?, value: false}
      ],
      'provenance' =>[
          { message: :active?, value: false},
          { message: :active_or_labware?, value: false},
          { message: :active_or_provenance?, value: true},
          { message: :active_or_dispatch?, value: false},
          { message: :active_or_awaiting?, value: false},
          { message: :pending?, value: true},
          { message: :broken?, value: false},
          { message: :claimed?, value: false},
          { message: :ready_for_claim?, value: false}          
      ],
      'dispatch' => [
          { message: :active?, value: false},
          { message: :active_or_labware?, value: false},
          { message: :active_or_provenance?, value: false},
          { message: :active_or_dispatch?, value: true},
          { message: :active_or_awaiting?, value: false},
          { message: :pending?, value: true},
          { message: :broken?, value: false},
          { message: :claimed?, value: false},
          { message: :ready_for_claim?, value: false}          
      ],
      'labware' => [
          { message: :active?, value: false},
          { message: :active_or_labware?, value: true},
          { message: :active_or_provenance?, value: false},
          { message: :active_or_dispatch?, value: false},
          { message: :active_or_awaiting?, value: false},
          { message: :pending?, value: true},
          { message: :broken?, value: false},
          { message: :claimed?, value: false},
          { message: :ready_for_claim?, value: false}          
      ]
    }

    @tests_status.each do |status, testing_list|
      testing_list.each do |obj|
        context "with a submission in status #{status}" do
          it "tests that #{obj[:message]} returns #{obj[:value]}" do
            s = build :material_submission, status: status
            expect(s.send(obj[:message])).to eq(obj[:value])
          end
        end
      end
    end
  end
end
