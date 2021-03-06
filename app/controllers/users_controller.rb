class UsersController < ApplicationController
  before_filter :require_account_admin, :except => [:show, :edit]
  before_filter(:except => [:new, :create, :index]) { require_user_for_current_account(params[:id]) }
  before_filter(:only => [:edit, :update]) { require_user_owned_by_current_user(params[:id]) }
  
  def create
    @user = User.new params[:user]
    @user.validate_password = false
    
    if @user.valid?
      
      existing_user = User.find(:first, :conditions => ["lower(email) = ?", @user.email.downcase])
      if existing_user.nil?
        @user.save
        @user.accounts << current_account
        
        reset_forgot_hash_for @user
        UserNotifier.welcome_new_user(@user, current_account, params[:msg], current_user).deliver
        flash[:success] = "#{@user.name_or_email} was added to your church! "
        redirect_to users_path
      else
        if existing_user.accounts(current_account).exists?
          flash[:error] = "That email address already belongs to a person with your church. "
          @title = 'All users'
          @sidebar_partial = 'users/sidebar/placeholder'
          render 'new'
        else
          existing_user.accounts << current_account
          
          UserNotifier.welcome_existing_user(@user, current_account, params[:msg], current_user).deliver
          flash[:success] = "#{existing_user.name_or_email} was added to your church! "
          redirect_to users_path
        end
      end

    else
      @title = "All people"
      @sidebar_partial = 'users/sidebar/placeholder'
      render 'new'
    end
  end
  
  def new
    @title = 'All people'
    @user = User.new
    @sidebar_partial = 'users/sidebar/placeholder'
  end
  
  def edit
    @user = User.find(params[:id])
    
    if @user == current_user
      @sidebar_partial = 'users/sidebar/placeholder'
      @title = "Your info"
    else
      @sidebar_partial = 'users/sidebar/edit_user'
      @title = "All people"
    end
    
    unless current_account.users.exists? @user
      flash[:error] = "You don't have permission to access that person. "
      redirect_to current_user
    end 
  end
  
  def update
    @user = User.find(params[:id])
    @user.validate_password = false
    
    if current_account.users.exists? @user
      if @user.update_attributes(params[:user])
        flash[:success] = "The settings for this person have been saved successfully. "
        redirect_to edit_user_path @user
      else
        if @user == current_user
          @title = "Your info"
        else
          @title = "All people"
        end
        @sidebar_partial = 'users/sidebar/placeholder'
        render 'edit'
      end
    else
      flash[:error] = "You don't have permission to access that person. "
      redirect_to current_user
    end
  end
  
  def index
    @users = current_account.users.all

    @title = 'All people'
    render :layout => 'full'
  end

  def show
    @teams = current_account.teams
    @user = User.find(params[:id])
    unless current_account.users.exists? @user
      flash[:error] = "You don't have permission to access that person. "
      redirect_to current_user
    end 

    @sidebar_partial = 'users/sidebar/placeholder'
    @title = 'Dashboard'
  end
  
  def destroy
    @user = User.find(params[:id])
    
    unless @user.id == current_user.id
      if current_account.users.exists? @user
        accountship = Accountship.where('user_id = ? AND account_id = ?', @user.id, current_account.id)
        Accountship.destroy accountship
        
        if @user.accounts.empty?
          User.destroy @user
        end
        
        flash[:success] = "#{@user.name_or_email} has been deleted. "
        redirect_to users_path
      else
        flash[:error] = "You don't have permission to access that person. "
        redirect_to current_user
      end
    else
      flash[:error] = "You are not allowed to remove your own account. "
      redirect_to edit_user_path(@user)
    end
  end
  
  def memberships_for
    @user = User.find(params[:id])
    @team_ids = Array.new(params[:team_id] || [])
    teams = current_account.teams
    
    teams.each do |team|
      if @team_ids.include?(team.id.to_s)
        Membership.set_to_active(team.id, @user.id)
      else
        Membership.set_to_inactive(team.id, @user.id)
      end
    end
    redirect_to edit_user_url(@user), :flash => { :success => "Team access for this person was changed" }
  end
    
  def send_reset
    @user = User.find(params[:id])
    reset_forgot_hash_with_timeout_for(@user)
    UserNotifier.forgot_password(@user).deliver
    flash[:success] = "This person has been emailed instructions to change their password. "
    redirect_to edit_user_url(@user)
  end
  
  private
  
    def require_user_owned_by_current_user(user_id)
      unless admin?
        user = User.find(user_id)
        
        user_team_ids = User.find(user_id).memberships.active.collect { |membership| membership.team_id }
        allowed_team_ids = User.find(current_user.id).memberships.admin.collect { |membership| membership.team_id }

        unless (user_team_ids & allowed_team_ids).any?
          redirect_to current_user, :flash => { :error => "You don't have permission for that person. "}
        end
      end
    end
end
