module ApplicationHelper
  def title
    "#{APP_NAME} | #{@title}"
  end
  
  def header_text
    unless current_account.nil?
      current_account.name
    else
      APP_NAME
    end
  end
end
