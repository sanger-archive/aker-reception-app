require 'event_publisher'

class EventMessage
  attr_reader :submission
  attr_reader :reception

  def initialize(params)
    @submission = params[:submission]
    @reception = params[:reception]
  end

  def trace_id
    ZipkinTracer::TraceContainer.current&.next_id&.trace_id&.to_s
  end

  def deputies
    StampClient::Deputy.where(user_email: @submission.owner_email).map(&:deputy)
  end

  # wrapper method to create the JSON message
  def generate_json
    if @submission
      generate_submission_json
    elsif @reception
      generate_reception_json
    end
  end

  # generate the JSON message specific to a submission
  def generate_submission_json
    {
      "event_type": "aker.events.submission.created",
      "lims_id": "aker",
      "uuid": SecureRandom.uuid,
      "timestamp": Time.now.utc.iso8601,
      "user_identifier": @submission.owner_email,
      "roles": [
        {
          "role_type": "submission",
          "subject_type": "submission",
          "subject_friendly_name": "Submission #{@submission.id}",
          "subject_uuid": @submission.material_submission_uuid,
        },
      ],
      "metadata": {
        "submission_id": @submission.id,
        "hmdmc_number": @submission.first_hmdmc,
        "confirmed_no_hmdmc": @submission.first_confirmed_no_hmdmc,
        "sample_custodian": @submission.contact.email,
        "total_samples": @submission.total_samples,
        "zipkin_trace_id": trace_id,
        "deputies": deputies,
      },
    }.to_json
  end

  # genereate the JSON message specific to a reception
  def generate_reception_json
    submission = @reception.labware.material_submission
    {
      "event_type": "aker.events.submission.received",
      "lims_id": "aker",
      "uuid": SecureRandom.uuid,
      "timestamp": Time.now.utc.iso8601,
      "user_identifier": submission.owner_email,
      "roles": [
        {
          "role_type": "submission",
          "subject_type": "submission",
          "subject_friendly_name": "Submission #{submission.id}",
          "subject_uuid": submission.material_submission_uuid,
        },
      ],
      "metadata": {
        "barcode": @reception.barcode_value,
        "samples": @reception.labware.contents.length,
        "zipkin_trace_id": trace_id,
        "created_at": @reception.created_at.to_time.utc.iso8601,
        "sample_custodian": submission.contact.email,
        "all_received": @reception.all_received?
      },
    }.to_json
  end

end
