class PagesController < ApplicationController
  skip_before_filter :authenticate

  def home
    @title = 'home'
  end
end
