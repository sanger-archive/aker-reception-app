module ApplicationHelper
  def title(page_name)
    "#{page_name.strip} | Aker"
  end

  def user_is_ssr
    current_user.groups.any? { |group| group.in? Rails.configuration.ssr_groups }
  end
end
