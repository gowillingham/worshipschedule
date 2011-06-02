class MembershipsController < ApplicationController
  before_filter(:except => 'show') { require_account_or_team_admin(params[:team_id]) }
  before_filter(:only => 'create') { require_user_for_current_account(params[:user_id]) }
  before_filter { require_team_for_current_account(params[:team_id]) }
  
  def create
    @membership = Membership.toggle_active(params[:team_id], params[:user_id])
    respond_to do |format|
      format.html { render :nothing => true }
      format.json { render :json => @membership }
    end
  end

  def index
    @team = Team.find(params[:team_id])
    @title = 'People on this team'
    @users = User.joins(:memberships).where('memberships.active = ? AND memberships.team_id = ?', true, @team.id)
    render :layout => 'full'
  end
  
  private
  
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
