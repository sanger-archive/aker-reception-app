require 'event_publisher'

class EventMessage
  attr_reader :submission
  attr_reader :reception

  def initialize(params)
    @submission = params[:submission]
    @reception = params[:reception]
  end

  # ?
  def self.annotate_zipkin(span)
    @trace_id = span.to_h[:traceId]
  end

  # ?
  def self.trace_id
    @trace_id
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
      "event_type": "aker.events.submission.#{@submission.status}",
      "lims_id": "aker",
      "uuid": SecureRandom.uuid,
      "timestamp": Time.now.utc.iso8601,
      "user_identifier": @submission.user.email,
      "roles": [
        {
          "role_type": "submission",
          "subject_type": "submission",
          "subject_friendly_name": "submission.?",
          "subject_uuid": @submission.id,
        },
      ],
      "metadata": {
        "hmdmc_number": @submission.first_hmdmc,
        "confirmed_no_hmdmc": @submission.first_confirmed_no_hmdmc,
        "sample_custodian": @submission.contact.email,
        "total_samples": @submission.total_samples,
        "zipkin_trace_id": EventMessage.trace_id,
        # "num_materials": @submission.set.meta["size"],
      },
    }.to_json
  end

  # genereate the JSON message specific to a reception
  def generate_reception_json
    submission = @reception.labware.material_submission
    {
      "event_type": "aker.events.submission.#{submission.status}",
      "lims_id": "aker",
      "uuid": SecureRandom.uuid,
      "timestamp": Time.now.utc.iso8601,
      "user_identifier": submission.user.email,
      "roles": [
        {
          "role_type": "submission",
          "subject_type": "submission",
          "subject_friendly_name": "submission.?",
          "subject_uuid": submission.id,
        },
      ],
      "metadata": {
        "barcode": @reception.barcode_value,
        "samples": @reception.labware.size,
        "zipkin_trace_id": EventMessage.trace_id,
      },
    }.to_json
  end

end
