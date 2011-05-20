class MembershipsController < ApplicationController
  before_filter(:except => 'show') { require_account_or_team_admin(params[:team_id]) }
  
  def index
    @team = Team.find(params[:team_id])
    @users = @team.users.all
    
    render :layout => 'full'
  end
  
  private
  
    def require_account_or_team_admin(team_id)
      team = Team.find(team_id)
      unless admin? || team_admin?(team, current_user)
        redirect_to current_user, :flash => { :error => "You don't have permission for that page" }
      end
    end
    
    def team_admin?(team, user)
      membership = Membership.where('user_id = ? AND team_id = ?', user.id, team.id).first
      if membership.nil?
        false
      else
        membership.admin?
      end
    end
end
