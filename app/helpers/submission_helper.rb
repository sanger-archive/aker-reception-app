module SubmissionHelper
  def available_contacts_select_options
    [['None', '']] + ContactGroup.all_contacts.map { |c| [c.fullname_and_email, c.id] }
  end

  def available_labware_types_select_options
    LabwareType.all.map{|c| ["#{c.name} (#{c.description})", c.id]}
  end

  def hmdmc_info
    "<p>Commercially available human cell lines are defined as "\
    "human cells that have been cultured and have divided "\
    "outside the body, and have been purchased from a "\
    "recognised commercial supplier.</p>\n"\
    "<p>This definition does not include, for example, "\
    "cell lines obtained from a collaborating academic "\
    "institution.</p>".html_safe
  end

  def step_classes(step_index)
    if params[:id] == wizard_steps[step_index].to_s
      "active"
    elsif step_index < wizard_steps.find_index(params[:id].to_sym)
      "complete"
    else
      "upcoming"
    end
  end

  def step_titles
    ["Container Type", "Biomaterial Metadata", "Ethics", "Delivery Details"]
  end

end
