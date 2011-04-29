class ProfilesController < ApplicationController
  skip_before_filter :authenticate, :only => [:forgot, :send_reset, :reset, :update_reset]
  skip_before_filter :check_account, :only => [:forgot, :send_reset, :reset, :update_reset]
  
  def edit
    @user = User.find(current_user.id)
    @sidebar_partial = 'users/sidebar/placeholder'
    @title = 'Your profile'
    render 'edit'
  end
  
  def update
    @user = User.find(current_user.id)
    @user.validate_password = true
    
    if @user.update_attributes(params[:user])
      flash[:success] = "Your password was changed. "
      redirect_to edit_profile_path
    else
      @sidebar_partial = 'users/sidebar/placeholder'
      @title = 'Your profile'
      render 'edit'
    end 
  end
  
  def forgot
    @title = "sign in"
    @user = User.new
    render :layout => 'signin'
  end
  
  def send_reset
    @user = User.find(:first, :conditions => [ "lower(email) = ?", params[:user][:email].downcase ])
    if @user.nil?
      flash[:error] = "Sorry, we couldn't find anyone with that email address. "
      redirect_to forgot_profile_url
    else
      refresh_forgot_hash @user
      UserNotifier.forgot_password(@user).deliver
      flash[:success] = "Instructions for signing in have been emailed to you. "
      redirect_to signin_url
    end
  end
  
  def reset
    @user = User.find_by_forgot_hash(params[:token])
    @title = 'sign in'
    
    if Time.now > (@user.forgot_hash_created_at + RESET_PASSWORD_TOKEN_TIMEOUT)
      render 'expired', :layout => 'signin'
    else
      render 'reset', :layout => 'signin'
    end
  end
  
  def update_reset
    @user = User.find(params[:id])
    @user.validate_password = true
    
    if @user.update_attributes(:password => params[:user][:password], :password_confirmation => params[:user][:password_confirmation])
      
      @user = User.authenticate(@user.email, params[:user][:password])
      if @user.nil?
        @title = 'sign in'
        flash.now[:error] = 'Invalid email/password combination.'
        render 'new', :layout => 'signin'
      else
        sign_in @user
        flash[:success] = "Welcome, #{@user.name_or_email}!"
        redirect_to_landing_page_for @user    
      end
      
    else
      render 'reset', :layout => 'signin'
    end
  end
end
