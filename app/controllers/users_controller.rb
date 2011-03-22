class UsersController < ApplicationController
  
  def new
    @title = 'New'
  end

  def show
    @user = User.find(params[:id])
  end
end
