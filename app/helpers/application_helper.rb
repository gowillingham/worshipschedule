module ApplicationHelper
  def title
    unless current_account.nil?
      "#{current_account.name} | #{@title}"
    else
      "#{APP_NAME} | #{@title}"
    end
  end
  
  def header_text
    unless current_account.nil?
      current_account.name
    else
      APP_NAME
    end
  end
end
