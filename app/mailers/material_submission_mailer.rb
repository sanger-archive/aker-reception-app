class MaterialSubmissionMailer < ApplicationMailer

  def submission_confirmation(material_submission)
    @material_submission = material_submission
    @contact_fullname = material_submission.contact.fullname
    mail(to: material_submission.owner_email, subject: "Material Submission #{@material_submission.id} confirmation")
  end

  def notify_contact(material_submission)
    @material_submission = material_submission
    @collaborator_email = material_submission.owner_email
    mail(to: material_submission.contact.email, subject: "New Material Submission #{@material_submission.id} created")
  end
end
