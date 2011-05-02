class AccountsController < ApplicationController
  skip_before_filter :authenticate, :only => [:new, :create]
  skip_before_filter :check_account, :except => [:show]
  
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
        @user.accountships.find_by_account_id(@account).toggle!(:admin)
        
        UserNotifier.welcome_new_account(@account, @user).deliver
        flash[:success] = "#{@account.name} was added to #{APP_NAME}. You'll need to create a password to sign in."
        redirect_to profile_reset_url(@user.forgot_hash)
      else
        reset_forgot_hash_with_timeout_for @user
        
        @account.users << @user
        @user.accountships.find_by_account_id(@account).toggle!(:admin)
        
        UserNotifier.welcome_new_account(@account, @user).deliver
        flash[:success] = "#{@account.name} was added to #{APP_NAME}. You just need to sign in."
        redirect_to signin_url
      end
    end
  end

  def show

  end
end
