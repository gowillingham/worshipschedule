class AccountsController < ApplicationController
  skip_before_filter :authenticate, :only => [:new, :create]
  skip_before_filter :check_account, :except => [:show]
  before_filter :require_account_admin, :only => [:admins, :update_admins, :edit]
  before_filter :require_account_owner, :only => [:edit, :update, :owner, :destroy]
  
  def destroy
    current_account.destroy
    sign_out
    redirect_to root_url, :notice => "We're sorry to see you go! Your account has been deleted and your associated data destroyed. "
  end
  
  def owner
    @account = Account.find(current_account.id)
    @new_owner = User.find(params[:account][:owner_id])
    
    if @account.users.exists?(@new_owner)
      if @account.update_attributes(params[:account])
        redirect_to current_user, :flash => { :success => 'The new owner was assigned to your account' }
      else
        @title = 'Settings'
        @sidebar_partial = 'accounts/sidebar/edit'
        render 'edit'
      end
    else
      redirect_to edit_account_url(@account), :error => 'You must assign a person from your own account as owner'
    end
  end
  
  def update
    @account = Account.find(current_account.id)
    if @account.update_attributes(params[:account])
      redirect_to edit_account_path(@account), :flash => { :success => 'The settings have been updated' }
    else
      @title = 'Settings'
      @sidebar_partial = 'accounts/sidebar/edit'
      render 'edit'
    end
  end
  
  def edit
    @account = current_account
    @title = 'Settings'
    @sidebar_partial = 'accounts/sidebar/edit'
    render 'edit'
  end
  
  def new
    @title = "New account"
    @account = Account.new
    render 'new', :layout => 'signin'
  end

  def create
    @account = Account.new(params[:account])
    
    if params[:user][:email].blank?
      @title = 'New'
      flash[:error] = "We'll need your email address to create a #{APP_NAME} account for your church!"
      
      render 'new', :layout => 'signin'
    else

      @account.save
      @user = User.find(:first, :conditions => ["lower(email) = ?", params[:user][:email].downcase])

      if @user.nil?
        @user = User.new(:email => params[:user][:email])
        @user.validate_password = false
        @user.save
        reset_forgot_hash_for @user
        
        @account.users << @user
        @account.owner = @user
        @account.save
        
        @user.accountships.find_by_account_id(@account).toggle!(:admin)
        
        UserNotifier.welcome_new_account(@account, @user).deliver
        flash[:success] = "Your church '#{@account.name}' was added to #{APP_NAME}! Just create a password to sign in."
        redirect_to profile_reset_url(@user.forgot_hash)
      else
        reset_forgot_hash_with_timeout_for @user
        
        @account.users << @user
        @account.owner = @user
        @account.save

        @user.accountships.find_by_account_id(@account).toggle!(:admin)
        
        UserNotifier.welcome_new_account(@account, @user).deliver
        flash[:success] = "Your church '#{@account.name}' was added to #{APP_NAME}. You just need to sign in."
        redirect_to signin_url
      end
    end
  end

  def admins
    @title = "Permissions"
    @accountships = Accountship.joins(:user).where(:account_id => current_account).order('CASE WHEN (LENGTH(last_name) = 0) THEN LOWER(email) ELSE LOWER(last_name) END')
    @sidebar_partial = "/users/sidebar/admins"
  end
  
  def update_admins
    @account = Account.find(params[:id])
    @account.assign_administrators(params[:accountship_ids] || [], current_user)
    flash[:success] = "Your administrator permission changes have been saved. "
    redirect_to users_url
  end
  
  def show
    @sidebar_partial = "/users/sidebar/placeholder"
  end
end
