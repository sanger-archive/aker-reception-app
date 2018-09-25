# frozen_string_literal: true

require 'event_publisher'

# Defines the message for the type of event which would be raised from manifest
class EventMessage
  attr_reader :manifest
  attr_reader :reception

  ROUTING_KEY = 'aker.events.manifest'

  def initialize(params)
    @manifest = params[:manifest]
    @reception = params[:reception]
  end

  # list all the deputies of a user, when fake_ldap is false
  def deputies
    return [] if Rails.configuration.fake_ldap
    manifest = @manifest || @reception.labware.manifest
    deputy_emails = []
    StampClient::Deputy.where(user_email: manifest.owner_email).map(&:deputy).each do |deputy|
      if deputy.include?('@')
        deputy_emails << deputy
      else
        deputy_emails += LDAPGroupReader.fetch_members(deputy).map(&:email)
      end
    end
    deputy_emails
  end

  # wrapper method to create the JSON message
  def generate_json
    if @manifest
      generate_submission_json
    elsif @reception
      generate_reception_json
    end
  end

  # generate the JSON message specific to a manifest
  def generate_submission_json
    {
      "event_type": 'aker.events.manifest.created',
      "lims_id": 'aker',
      "uuid": SecureRandom.uuid,
      "timestamp": Time.now.utc.iso8601,
      "user_identifier": @manifest.owner_email,
      "roles": [
        {
          "role_type": 'manifest',
          "subject_type": 'manifest',
          "subject_friendly_name": "Manifest #{@manifest.id}",
          "subject_uuid": @manifest.manifest_uuid
        }
      ],
      "metadata": {
        "manifest_id": @manifest.id,
        "hmdmc": @manifest.hmdmc_set.to_a,
        "confirmed_no_hmdmc": @manifest.first_confirmed_no_hmdmc,
        "sample_custodian": @manifest.contact.email,
        "total_samples": @manifest.total_samples,
        "deputies": deputies
      }
    }.to_json
  end

  # genereate the JSON message specific to a reception
  def generate_reception_json
    manifest = @reception.labware.manifest
    {
      "event_type": 'aker.events.manifest.received',
      "lims_id": 'aker',
      "uuid": SecureRandom.uuid,
      "timestamp": Time.now.utc.iso8601,
      "user_identifier": manifest.owner_email,
      "roles": [
        {
          "role_type": 'manifest',
          "subject_type": 'manifest',
          "subject_friendly_name": "Manifest #{manifest.id}",
          "subject_uuid": manifest.manifest_uuid
        }
      ],
      "metadata": {
        "manifest_id": manifest.id,
        "barcode": @reception.barcode_value,
        "samples": @reception.labware.contents.length,
        "created_at": @reception.created_at.to_time.utc.iso8601,
        "sample_custodian": manifest.contact.email,
        "all_received": @reception.all_received?,
        "deputies": deputies
      }
    }.to_json
  end
end
