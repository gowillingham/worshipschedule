class SessionsController < ApplicationController
  skip_before_filter :authenticate, :except => [:destroy, :accounts]
  skip_before_filter :check_account
  
  def new
    @user = User.new
    @title = 'sign in'
    render :layout => 'signin'
  end
  
  def create
    user = User.authenticate params[:session][:email], params[:session][:password]
    
    if user.nil?
      @title = 'sign in'
      flash.now[:error] = 'Invalid email/password combination.'
      render 'new', :layout => 'signin'
      
    else
      sign_in user
      flash[:success] = "Welcome, #{user.name_or_email}!"
      redirect_to_landing_page_for user      
    end
  end
  
  def destroy
    sign_out
    flash[:success] = "Ok. Signed out. "
    redirect_to signin_path, :layout => 'signin'
  end

  def accounts
    @accounts = current_user.accounts
    
    @title = "Churches for #{current_user.name_or_email}"
    @sidebar_partial = 'users/sidebar/placeholder'
    @context = "accounts"
  end
  
  def set_account
    account = Account.find_by_id(params[:id])
    set_session_account account
    redirect_to current_user
  end
end
