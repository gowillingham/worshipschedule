class TeamsController < ApplicationController
  def show
    @team = Team.find(params[:id])
    @sidebar_partial = 'users/sidebar/placeholder'
    @context = 'teams'
  end
end
