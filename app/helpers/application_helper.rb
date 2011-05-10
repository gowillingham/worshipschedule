module ApplicationHelper
  def title
    unless current_account.nil?
      "#{current_account.name} | #{@title}"
    else
      "#{APP_NAME} | #{@title}"
    end
  end
end
