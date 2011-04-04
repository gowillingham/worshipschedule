class SessionsController < ApplicationController
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
    
  end
end
