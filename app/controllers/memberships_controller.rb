class MembershipsController < ApplicationController
  before_filter :require_account_admin, :except => 'show'
  
  def index
    @team = Team.find(:team_id)
    @users = Team.users
    
    render :layout => 'full'
  end
end
