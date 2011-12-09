class TeamsController < ApplicationController
  before_filter :require_account_admin, :only => [:destroy, :create, :new]
  before_filter(:only => [:assign, :edit, :update, :assign_all, :remove_all]) { require_account_or_team_admin(params[:id]) }
  before_filter(:except => [:create, :new]) { require_team_for_current_account(params[:id]) }

  def assign_all
    @team = Team.find(params[:id])
    Team.add_all_account_users(current_account, @team)
    redirect_to assign_team_url(@team)
  end
  
  def remove_all
    @team = Team.find(params[:id])
    Team.remove_all_account_users(@team)
    
    redirect_to assign_team_url(@team)
  end
  
  def assign
    @team = Team.find(params[:id])
    @members = current_account.users(:all, :include => [:teams, :memberships])

    @title = 'People for this team'
    @sidebar_partial = 'users/sidebar/placeholder'
    render :layout => 'full'
  end
  
  def destroy
    @team = Team.find(params[:id])
    @team.destroy
    flash[:success] = 'The team was removed from your account'
    redirect_to current_user
  end
  
  def show
    @team = Team.find(params[:id])
    @sidebar_partial = 'users/sidebar/placeholder'
  end
  
  def new
    @team = Team.new
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
      render 'new'
    end
  end
  
  def edit
    @team = Team.find(params[:id])
    @sidebar_partial = 'teams/sidebar/edit'
  end
  
  def update
    @team = Team.find(params[:id])
    @sidebar_partial = 'users/sidebar/placeholder'
    
    if @team.update_attributes(params[:team])
      flash.now[:success] = 'Team settings have been updated'
      render 'edit'
    else
      render 'edit'
    end
  end
  
  def admins
    @team = Team.find(params[:id])
    @sidebar_partial = 'users/sidebar/placeholder'
  end
  
  def update_admins
  end
end
