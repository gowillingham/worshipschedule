class MembershipsController < ApplicationController
  before_filter(:except => 'show') { require_account_or_team_admin(params[:team_id]) }
  before_filter(:only => 'create') { require_user_for_current_account(params[:user_id]) }
  before_filter { require_team_for_current_account(params[:team_id]) }
  
  def create
    @membership = Membership.create(:user_id => params[:user_id], :team_id => params[:team_id])
    respond_to do |format|
      format.html {}
      format.json { render :json => @membership }
    end
    render :nothing => true
  end

  def index
    @team = Team.find(params[:team_id])
    @users = @team.users.joins(:memberships).where('memberships.active = ?', true)
    
    render :layout => 'full'
  end
  
  private
  
    def require_team_for_current_account(team_id)
      team = Team.find(team_id)
      unless current_account.teams.exists?(team)
        redirect_to current_user, :flash => { :error => "You don't have permission to modify that team" }
      end
    end
    
    def require_user_for_current_account(user_id)
      user = User.find(user_id)
      unless current_account.users.exists?(user)
        respond_to do |format|
          format.html { redirect_to current_user, :flash => { :error => "You don't have permission to modify that person" } }
          format.json { render :nothing => true, :status => :forbidden }
        end
      end
    end
end
