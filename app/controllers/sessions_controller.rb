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
      flash[:success] = "Welcome, #{user.name_or_email}!"
      
      if user.accounts.empty?
        # todo: handle orphaned users ..
        redirect_to user
      elsif user.accounts.size == 1
        current_account = user.accounts.find :first
        session[:account_id] = current_account.id
        redirect_to user
      else
        redirect_to sessions_accounts_path
      end
    end
  end
  
  def destroy
    sign_out
    flash[:success] = "Ok. Signed out. "
    redirect_to root_path
  end

  def accounts
    @context = "dashboard"
    @accounts = current_user.accounts
  end
  
  def set_account
    account = Account.find_by_id(params[:id])
    session[:account_id] = account.id
    current_account = account
    redirect_to current_user
  end
end
