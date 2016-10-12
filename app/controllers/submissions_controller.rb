class SubmissionsController < ApplicationController

  include Wicked::Wizard
  steps :labware, :provenance, :dispatch

  def show
    render_wizard
  end

  def update
    params[:material_submission][:status] = step.to_s
    params[:material_submission][:status] = 'active' if last_step?

    updating_params = material_submission_params
    case step
    when :dispatch
      if material_submission_params[:contact].empty?
        flash[:error] = "You need to provide a contact"
        redirect_to material_submission_build_path material_submission_id: material_submission.id
        return
      else
        set_contact
        updating_params = updating_params.merge({:contact => @contact})
      end
    end
    if material_submission.update_attributes(updating_params) && last_step?
      flash[:notice] = 'Your Submission has been created'
    end

    render_wizard material_submission
  end

  protected

  def material_submission
    @material_submission ||= MaterialSubmission.find(params[:material_submission_id])
  end

  def last_step?
    step == steps.last
  end

  def first_step?
    step == steps.first
  end

  helper_method :material_submission, :last_step?, :first_step?

  private

  def material_submission_params
    params.require(:material_submission).permit(
      :supply_labwares, :no_of_labwares_required, :status, :labware_type_id, :address, :contact, labwares_attributes: [
        :id,
        wells_attributes: [
          :id,
          :position,
          biomaterial_attributes: [ :id, :supplier_name, :donor_name, :gender, :common_name, :phenotype ]]
      ]
    )
  end

  def set_contact
    @contact = Contact.find_by_email(material_submission_params[:contact])
    if @contact.nil?
      @contact = Contact.create(:email => material_submission_params[:contact])
    end
  end



end
