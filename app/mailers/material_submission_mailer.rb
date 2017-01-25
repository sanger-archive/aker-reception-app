class MaterialSubmissionMailer < ApplicationMailer

  def submission_confirmation(material_submission)
    @material_submission = material_submission
    @contact_fullname = material_submission.contact.fullname
    mail(to: material_submission.email, subject: "Material Submission Confirmation")
  end

  def notify_contact(material_submission)
    @material_submission = material_submission
    @collaborator_email = material_submission.email
    mail(to: material_submission.contact.email, subject: "New Material Submission Created")
  end
end
