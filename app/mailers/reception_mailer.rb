class ReceptionMailer < ApplicationMailer

  def material_reception(r)
    @material_reception = r
    @labware = @material_reception.labware
    @material_submission = @labware.material_submission
    @contact = @material_submission.contact
    mail(to: @contact.email, subject: "Material received at #{@material_reception.created_at}")
  end

  def complete_set(r)
    @material_reception = r
    @labware = @material_reception.labware
    @labwares = @labware.material_submission.labwares
    @material_submission = @labware.material_submission
    @contact = @material_submission.contact
    mail(to: @contact.email, subject: "Complete set received")
  end

end
