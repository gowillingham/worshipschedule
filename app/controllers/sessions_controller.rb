class SessionsController < ApplicationController
  skip_before_filter :authenticate, :except => [:destroy, :accounts]
  
  def new
    @user = User.new
    @title = 'sign in'
  end
  
  def create
    user = User.authenticate params[:session][:email], params[:session][:password]
    
    if user.nil?
      @title = 'sign in'
      flash.now[:error] = 'Invalid email/password combination.'
      render 'new'
      
    else
      sign_in user
      flash[:success] = "Welcome, #{user.name}!"
      
      if user.accounts.empty?
        # todo: handle orphaned users ..
        redirect_to user
      elsif user.accounts.size == 1
        # todo: set current account in the session ..
        redirect_to user
      else
        redirect_to sessions_accounts_path
      end
    end
  end
  
  def accounts
    
  end

  def destroy
    sign_out
    flash[:success] = "Ok. Signed out. "
    redirect_to root_path
  end
end
