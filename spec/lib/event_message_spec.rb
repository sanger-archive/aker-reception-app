# frozen_string_literal: true

require 'rails_helper'
require 'set'

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
      allow(submission).to receive(:hmdmc_set).and_return Set.new(['12/000', '13/999'])
      allow(submission).to receive(:total_samples).and_return 12
      allow(submission).to receive(:first_confirmed_no_hmdmc).and_return 'test@test.com'

      message = EventMessage.new(submission: submission)

      allow(message).to receive(:deputies).and_return %w[ab1 group1]

      Timecop.freeze do
        json = JSON.parse(message.generate_json)

        expect(json['event_type']).to eq 'aker.events.manifest.created'
        expect(json['lims_id']).to eq 'aker'
        expect(json['uuid']).to eq 'a_uuid'
        expect(json['timestamp']).to eq Time.now.utc.iso8601
        expect(json['user_identifier']).to eq submission.owner_email
        expect(json['metadata']['hmdmc']).to eq ['12/000', '13/999']
        expect(json['metadata']['sample_custodian']).to eq submission.contact.email
        expect(json['metadata']['total_samples']).to eq 12
        expect(json['metadata']['confirmed_no_hmdmc']).to eq 'test@test.com'
      end
    end

    it 'for a reception' do
      material_submission = create(:material_submission, status: MaterialSubmission.PRINTED)
      labware = create(:printed_with_contents_labware,
                       material_submission: material_submission)
      reception = build(:material_reception, labware_id: labware.id)

      allow(material_submission).to receive(:id).and_return material_submission.id
      allow(SecureRandom).to receive(:uuid).and_return 'a_uuid'
      allow(reception).to receive(:barcode_value).and_return 'AKER-1'
      allow(reception).to receive(:created_at).and_return Time.now.utc.iso8601
      allow(reception).to receive(:all_received?).and_return true

      message = EventMessage.new(reception: reception)

      allow(message).to receive(:deputies).and_return %w[ab1 group1]

      Timecop.freeze do
        json = JSON.parse(message.generate_json)

        expect(json['event_type']).to eq 'aker.events.manifest.received'
        expect(json['lims_id']).to eq 'aker'
        expect(json['uuid']).to eq 'a_uuid'
        expect(json['timestamp']).to eq Time.now.utc.iso8601
        expect(json['user_identifier']).to eq labware.material_submission.owner_email
        expect(json['metadata']['manifest_id']).to eq material_submission.id
        expect(json['metadata']['barcode']).to eq 'AKER-1'
        expect(json['metadata']['samples']).to eq reception.labware.contents.length
        expect(json['metadata']['created_at']).to eq Time.now.utc.iso8601
        expect(json['metadata']['sample_custodian']).to eq material_submission.contact.email
        expect(json['metadata']['all_received']).to eq true
        expect(json['metadata']['deputies']).to eq %w[ab1 group1]
      end
    end
  end
end
