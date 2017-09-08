require 'rails_helper'

RSpec.describe 'EventMessage' do

  context '#initialize messages' do
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

  context '#generates JSON' do
    it 'generates json for a submission' do

      submission = build(:material_submission, status: MaterialSubmission.ACTIVE)

      allow(SecureRandom).to receive(:uuid).and_return 'a_uuid'

      message = EventMessage.new(submission: submission)

      allow(EventMessage).to receive(:trace_id).and_return 'a_trace_id'

      Timecop.freeze do
        json = JSON.parse(message.generate_json)

        expect(json["event_type"]).to eq "aker.events.submission.#{MaterialSubmission.ACTIVE}"
        expect(json["lims_id"]).to eq 'aker'
        expect(json["uuid"]).to eq 'a_uuid'
        expect(json["timestamp"]).to eq Time.now.utc.iso8601
        expect(json["user_identifier"]).to eq submission.user.email
        expect(json["metadata"]["hmdmc_number"]).to eq submission.first_hmdmc
        expect(json["metadata"]["sample_custodian"]).to eq submission.contact.email
        expect(json["metadata"]["total_samples"]).to eq submission.total_samples
        expect(json["metadata"]["zipkin_trace_id"]).to eq 'a_trace_id'
        expect(json["metadata"]["confirmed_no_hmdmc"]).to eq submission.first_confirmed_no_hmdmc
      end
    end

    it 'generates json for a reception' do

      labware = create(:labware_with_barcode_and_material_submission, material_submission: build(:material_submission, status: MaterialSubmission.PRINTED))
      reception = build(:material_reception, labware_id: labware.id)

      allow(SecureRandom).to receive(:uuid).and_return 'a_uuid'

      message = EventMessage.new(reception: reception)

      allow(EventMessage).to receive(:trace_id).and_return 'a_trace_id'

      Timecop.freeze do
        json = JSON.parse(message.generate_json)

        expect(json["event_type"]).to eq "aker.events.submission.#{MaterialSubmission.PRINTED}"
        expect(json["lims_id"]).to eq 'aker'
        expect(json["uuid"]).to eq 'a_uuid'
        expect(json["timestamp"]).to eq Time.now.utc.iso8601
        expect(json["user_identifier"]).to eq labware.material_submission.user.email
        expect(json["metadata"]["barcode"]).to eq reception.barcode_value
        expect(json["metadata"]["samples"]).to eq reception.labware.size
        expect(json["metadata"]["zipkin_trace_id"]).to eq 'a_trace_id'
      end
    end
  end

end
