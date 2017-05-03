class MailService

  attr_reader :material_submission

  def initialize(material_submission)
    @material_submission = material_submission
  end

  def up
      MaterialSubmissionMailer.submission_confirmation(material_submission).deliver_later
      MaterialSubmissionMailer.notify_contact(material_submission).deliver_later
  end

  def down
  end
  
end