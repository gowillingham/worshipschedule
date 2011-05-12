module UsersHelper
  def gravatar_for(user, options = { :size => 50, :default => :identicon })
    gravatar_image_tag(
      user.email.downcase,
      :alt => user.name,
      :class => 'gravatar',
      :gravatar => options
    )
  end
  
  def link_for_new_team
    "<ul><li>#{link_to "New team", new_team_path, :class => 'cancel'}</li></ul>".html_safe
  end
end
