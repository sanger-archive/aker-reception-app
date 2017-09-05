module ApplicationHelper
  def title(page_name)
    "#{page_name.strip} | Aker"
  end

  def navlinks
    (
    "<li>#{link_to 'Creation', material_submissions_path, id: ('current_page' if (params[:controller] == 'material_submissions' && params[:action] != 'show') || params[:controller] == 'submissions')}</li>" +
    "<li>#{link_to 'Print', completed_submissions_path, id: ('current_page' if params[:controller] == 'completed_submissions')}</li>" +
    "<li>#{link_to 'Reception', material_receptions_path, id: ('current_page' if params[:controller] == 'material_receptions')}</li>" +
    "<li>#{link_to 'Claim', claim_submissions_path, id: ('current_page' if params[:controller] == 'claim_submissions')}</li>"
    ).html_safe
  end
end
