class PagesController < ApplicationController
  skip_before_filter :authenticate
  skip_before_filter :check_account

  def home
    @title = 'home'
    render :layout => 'signin'
  end
end
