class TeamsController < ApplicationController
  before_filter :require_account_admin, :only => [:destroy, :create, :new]
  before_filter(:only => [:assign, :edit, :update, :assign_all, :remove_all, :admins, :update_admins]) { require_account_or_team_admin(params[:id]) }
  before_filter(:except => [:create, :new]) { require_team_for_current_account(params[:id]) }
  before_filter(:only => [:show, :slots]) { require_team_member(params[:id]) }
  before_filter(:only => [:slots]) { require_events_from_current_team(params[:id], params[:show_events])}
 
  def slots
    @team = Team.find(params[:id])
    @skillships = Skillship.find(
      :all, 
      :joins => { :membership => :user },
      :select => 'skillships.id, skillships.skill_id AS skill_id, users.first_name, users.last_name, users.email, memberships.id AS membership_id',
      :conditions => ['memberships.team_id = ?', @team.id],
      :order => 'CASE WHEN (LENGTH(last_name) = 0) THEN LOWER(email) ELSE LOWER(last_name) END'
      )
    @slots = Slot.find(
      :all,
      :joins => [:event, :skillship => [:skill, { :membership => :user }]],
      :order => 'CASE WHEN (LENGTH(last_name) = 0) THEN LOWER(email) ELSE LOWER(last_name) END'
      )
      
    if params[:reset_events?]
      @selected_events = Event.find(params[:show_events]).sort { |a,b| a.start_at <=> b.start_at } unless params[:show_events].blank?
      session[@team.id] ||= {}
      session[@team.id][:show_events] = params[:show_events]
    else
      session[@team.id] ||= {}
      if session[@team.id][:show_events].nil?
        @selected_events = @team.events.all.sort { |a,b| a.start_at <=> b.start_at } if @team.events.any?
      else
        @selected_events = Event.find(session[@team.id][:show_events]).sort { |a,b| a.start_at <=> b.start_at } unless session[@team.id][:show_events].blank?
      end
    end
    @selected_events ||= []
    
    @cols = 3
    @title = "Schedule people"
    
    @sidebar_partial = 'teams/sidebar/slots'
    render :layout => 'medium'
  end
  
  def admins
    @team = Team.find(params[:id])
    @account_admins = User.joins(:accountships).where('accountships.account_id = ? AND accountships.admin = ?', current_account.id, true)

    @memberships = @team.memberships.joins(:user).where(:active => true).order('CASE WHEN (LENGTH(last_name) = 0) THEN LOWER(email) ELSE LOWER(last_name) END')
    @title = 'Team administrators'
    @sidebar_partial = 'teams/sidebar/admins'
  end
  
  def update_admins
    @team = Team.find(params[:id])    
    
    if !admin? && !params[:membership_id].include?(current_user.memberships.where(:team_id => @team.id).first.id.to_s)
      flash[:error] = "You cannot remove yourself from this team's administrators. You will need to get an account administrator to do so. "
      redirect_to admins_team_url(@team)
    else
      @team.assign_administrators(params[:membership_id], current_user)
      flash[:success] = 'Your team administrator permission changes have been saved'
      redirect_to edit_team_url(@team)
    end
  end

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
    @memberships = Membership.joins(:user).where("team_id = ? AND active = ?", @team.id, true).all
    @memberships.sort! { |a,b| a.user.sortable_name.downcase <=> b.user.sortable_name.downcase }
    @events = @team.events.all
    
    @title = "Team details"
    @sidebar_partial = 'teams/sidebar/show'
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
    @admin_accountships = current_account.accountships.joins(:user).where(:admin => true)
    @admin_accountships.sort! { |a,b| a.user.sortable_name.downcase <=> b.user.sortable_name.downcase }
    @admin_memberships = @team.memberships.admin
    @admin_memberships.sort! { |a,b| a.user.sortable_name.downcase <=> b.user.sortable_name.downcase }
    @sidebar_partial = 'teams/sidebar/edit'
    @title = 'Team settings'
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
  
  private
  
    def require_events_from_current_team(team_id, event_id_list)
      unless event_id_list.blank?
        team = Team.find(team_id)
        events = Event.find(event_id_list)
      
        unless (team.events & events) == events
          redirect_to current_user, :flash => { :error => "You don't have permission to view that team" }        
        end
      end
    end
end
