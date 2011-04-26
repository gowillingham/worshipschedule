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
    
  end
  
  def send_reset
    
  end
  
  def reset
    
  end
end
