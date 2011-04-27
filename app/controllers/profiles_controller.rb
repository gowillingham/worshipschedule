class ProfilesController < ApplicationController
  skip_before_filter :authenticate, :only => [:forgot, :send_reset, :reset]
  skip_before_filter :check_account, :only => [:forgot, :send_reset, :reset]
  
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
  
  def reset
    @user = User.find_by_email(params[:user][:email])
    if @user.nil?
      flash[:error] = "Sorry, we couldn't find anyone with that email address. "
      redirect_to forgot_profile_url
    else
      # do stuff ..
      flash[:success] = "Instructions for signing in have been emailed to you. "
      redirect_to signin_url
    end
  end
  
  def send_reset
    
  end
end
