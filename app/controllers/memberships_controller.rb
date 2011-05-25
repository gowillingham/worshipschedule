class MembershipsController < ApplicationController
  before_filter(:except => 'show') { require_account_or_team_admin(params[:team_id]) }
  
  def edit
    
  end
  
  def index
    @team = Team.find(params[:team_id])
    @users = @team.users.joins(:memberships).where('memberships.active = ?', true)
    
    render :layout => 'full'
  end
  
  private
    
    def team_admin?(team, user)
      membership = Membership.where('user_id = ? AND team_id = ?', user.id, team.id).first
      if membership.nil?
        false
      else
        membership.admin?
      end
    end
end
