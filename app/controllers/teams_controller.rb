class TeamsController < ApplicationController
  before_filter :require_account_admin, :except => 'show'
  
  def show
    @team = Team.find(params[:id])
    @sidebar_partial = 'users/sidebar/placeholder'
    @context = 'teams'
  end
  
  def new
    @team = Team.new
    @context = 'new_team'
    @sidebar_partial = 'users/sidebar/placeholder'
  end
  
  def create
    @team = Team.new(params[:team])
    @team.account_id = current_account.id
    if @team.save
      flash[:success] = 'The new team was successfully saved'
      redirect_to @team
    else
      @sidebar_partial = 'users/sidebar/placeholder'
      @context = 'new_team'
      render 'new'
    end
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
      flash.now[:success] = 'Team settings have been updated'
      render 'edit'
    else
      render 'edit'
    end
  end
end
