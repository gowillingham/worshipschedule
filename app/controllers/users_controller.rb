class UsersController < ApplicationController
  
  def create
    @user = User.new params[:user]
    @user.password = generate_password
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
  
  def edit
    @user = User.find(params[:id])
  end
  
  def update
    
  end
  
  def index
    @context = 'users'
    @title = 'People'
    
    @users = current_account.users(:all)
    render :layout => 'full'
  end

  def show
    @user = User.find(params[:id])
    
    @context = 'dashboard'
    @title = @user.name_or_email
  end
end
