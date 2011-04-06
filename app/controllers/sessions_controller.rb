class SessionsController < ApplicationController
  skip_before_filter :authenticate, :except => [:destroy]
  
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
      redirect_to user
    end
  end

  def destroy
    sign_out
    flash[:success] = "Ok. Signed out. "
    redirect_to root_path
  end
end
