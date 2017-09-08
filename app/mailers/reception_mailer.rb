class ReceptionMailer < ApplicationMailer

  def material_reception(r)
    @material_reception = r
    @labware = @material_reception.labware
    @material_submission = @labware.material_submission
    @contact = @material_submission.contact
    subject = "Material received at #{@material_reception.created_at}"
    subject += " (Submission Complete)" if @material_reception.all_received?
    mail(to: @contact.email, subject: subject)
  end

end
