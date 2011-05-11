class TeamsController < ApplicationController
  before_filter :require_account_admin, :except => 'show'
  
  def show
    @team = Team.find(params[:id])
    @sidebar_partial = 'users/sidebar/placeholder'
    @context = 'teams'
  end
  
  def edit
    @team = Team.find(params[:id])
    @context = 'team_settings'
    @sidebar_partial = 'users/sidebar/placeholder'
  end
end
