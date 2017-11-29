require 'rails_helper'

RSpec.describe 'EventMessage' do

  describe '#initialize messages' do
    it 'is initalized with a params object for a submission' do
      s = instance_double('MaterialSubmission')
      message = EventMessage.new(submission: s)
      expect(message.submission).not_to be_nil
    end

    it 'is initalized with a params object for a reception' do
      r = instance_double('MaterialReception')
      message = EventMessage.new(reception: r)
      expect(message.reception).not_to be_nil
    end
  end

  describe '#generates JSON' do
    it 'for a submission' do

      submission = build(:material_submission, status: MaterialSubmission.ACTIVE)

      allow(SecureRandom).to receive(:uuid).and_return 'a_uuid'
      allow(submission).to receive(:first_hmdmc).and_return '12/000'
      allow(submission).to receive(:total_samples).and_return 12
      allow(submission).to receive(:first_confirmed_no_hmdmc).and_return 'test@test.com'

      message = EventMessage.new(submission: submission)

      allow(message).to receive(:trace_id).and_return 'a_trace_id'
      allow(message).to receive(:deputies).and_return ['ab1', 'group1']

      Timecop.freeze do
        json = JSON.parse(message.generate_json)

        expect(json["event_type"]).to eq "aker.events.submission.created"
        expect(json["lims_id"]).to eq 'aker'
        expect(json["uuid"]).to eq 'a_uuid'
        expect(json["timestamp"]).to eq Time.now.utc.iso8601
        expect(json["user_identifier"]).to eq submission.owner_email
        expect(json["metadata"]["hmdmc_number"]).to eq '12/000'
        expect(json["metadata"]["sample_custodian"]).to eq submission.contact.email
        expect(json["metadata"]["total_samples"]).to eq 12
        expect(json["metadata"]["zipkin_trace_id"]).to eq 'a_trace_id'
        expect(json["metadata"]["confirmed_no_hmdmc"]).to eq 'test@test.com'
      end
    end

    it 'for a reception' do
      labware = create(:labware_with_barcode_and_material_submission,
                       material_submission: build(:material_submission,
                                                  status: MaterialSubmission.PRINTED)                       )
      reception = build(:material_reception, labware_id: labware.id)

      allow(SecureRandom).to receive(:uuid).and_return 'a_uuid'
      allow(reception).to receive(:barcode_value).and_return 'AKER-1'
      allow(reception).to receive(:created_at).and_return Time.now

      message = EventMessage.new(reception: reception)

      allow(message).to receive(:trace_id).and_return 'a_trace_id'
      allow(message).to receive(:deputies).and_return ['ab1', 'group1']

      Timecop.freeze do
        json = JSON.parse(message.generate_json)

        expect(json["event_type"]).to eq "aker.events.submission.received"
        expect(json["lims_id"]).to eq 'aker'
        expect(json["uuid"]).to eq 'a_uuid'
        expect(json["timestamp"]).to eq Time.now.utc.iso8601
        expect(json["user_identifier"]).to eq labware.material_submission.owner_email
        expect(json["metadata"]["barcode"]).to eq 'AKER-1'
        expect(json["metadata"]["samples"]).to eq reception.labware.contents.length
        expect(json["metadata"]["zipkin_trace_id"]).to eq 'a_trace_id'
      end
    end
  end

end
