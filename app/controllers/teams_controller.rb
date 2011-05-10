class TeamsController < ApplicationController
  def show
    @sidebar_partial = 'users/sidebar/placeholder'
    @context = 'teams'
  end
end
