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
    @sidebar_partial = 'teams/sidebar/edit'
  end
  
  def update
    @team = Team.find(params[:id])
    @context = 'team_settings'
    @sidebar_partial = 'users/sidebar/placeholder'
    
    if @team.update_attributes(params[:team])
      flash[:success] = 'Team settings have been updated'
      render 'edit'
    else
      render 'edit'
    end
  end
end
