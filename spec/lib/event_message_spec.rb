# frozen_string_literal: true

require 'rails_helper'
require 'set'

RSpec.describe 'EventMessage' do
  describe '#initialize messages' do
    it 'is initalized with a params object for a manifest' do
      m = instance_double('Manifest')
      message = EventMessage.new(manifest: m)
      expect(message.manifest).not_to be_nil
    end

    it 'is initalized with a params object for a reception' do
      r = instance_double('MaterialReception')
      message = EventMessage.new(reception: r)
      expect(message.reception).not_to be_nil
    end
  end

  describe '#generates JSON' do
    it 'for a manifest' do
      manifest = build(:manifest, status: Manifest.ACTIVE)

      allow(SecureRandom).to receive(:uuid).and_return 'a_uuid'
      allow(manifest).to receive(:hmdmc_set).and_return Set.new(['12/000', '13/999'])
      allow(manifest).to receive(:total_samples).and_return 12
      allow(manifest).to receive(:first_confirmed_no_hmdmc).and_return 'test@test.com'

      message = EventMessage.new(manifest: manifest)

      allow(message).to receive(:deputies).and_return %w[ab1 group1]

      Timecop.freeze do
        json = JSON.parse(message.generate_json)

        expect(json['event_type']).to eq 'aker.events.manifest.created'
        expect(json['lims_id']).to eq 'aker'
        expect(json['uuid']).to eq 'a_uuid'
        expect(json['timestamp']).to eq Time.now.utc.iso8601
        expect(json['user_identifier']).to eq manifest.owner_email
        expect(json['metadata']['hmdmc']).to eq ['12/000', '13/999']
        expect(json['metadata']['sample_custodian']).to eq manifest.contact.email
        expect(json['metadata']['total_samples']).to eq 12
        expect(json['metadata']['confirmed_no_hmdmc']).to eq 'test@test.com'
      end
    end

    it 'for a reception' do
      manifest = create(:manifest, status: Manifest.PRINTED)
      labware = create(:printed_with_contents_labware,
                       manifest: manifest)
      reception = build(:material_reception, labware_id: labware.id)

      allow(manifest).to receive(:id).and_return manifest.id
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
        expect(json['user_identifier']).to eq labware.manifest.owner_email
        expect(json['metadata']['manifest_id']).to eq manifest.id
        expect(json['metadata']['barcode']).to eq 'AKER-1'
        expect(json['metadata']['samples']).to eq reception.labware.contents.length
        expect(json['metadata']['created_at']).to eq Time.now.utc.iso8601
        expect(json['metadata']['sample_custodian']).to eq manifest.contact.email
        expect(json['metadata']['all_received']).to eq true
        expect(json['metadata']['deputies']).to eq %w[ab1 group1]
      end
    end
  end
end
