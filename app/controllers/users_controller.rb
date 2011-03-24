class UsersController < ApplicationController
  
  def create
    @user = User.new params[:user]
    if @user.save
      flash[:success] = "Ok! #{@user.email} was successfully created! "
      redirect_to @user 
    else
      @title = "New"
      render 'new'
    end
  end
  
  def new
    @title = 'New'
    @user = User.new
  end

  def show
    @user = User.find(params[:id])
    @title = @user.name
  end
end
