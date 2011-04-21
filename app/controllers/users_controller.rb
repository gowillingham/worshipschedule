class UsersController < ApplicationController
  
  def create
    @user = User.new params[:user]
    @user.password = generate_password
    
    if @user.valid?
      
      existing_user = User.find(:first, :conditions => ["lower(email) = ?", @user.email.downcase])
      if existing_user.nil?
        @user.save
        @user.accounts << current_account
        flash[:success] = "#{@user.name_or_email} was added to your church! "
        redirect_to users_path
      else
        if existing_user.accounts(current_account).exists?
          flash[:error] = "That email address already belongs to a person in your account. "
          @title = 'New'
          render 'new'
        else
          existing_user.accounts << current_account
          flash[:success] = "#{existing_user.name_or_email} was added to your church! "
          redirect_to users_path
        end
      end

    else
      @title = "New"
      render 'new'
    end
  end
  
  def new
    @title = 'New'
    @user = User.new
    @context = 'users'
  end
  
  def edit
    @user = User.find(params[:id])
  end
  
  def update
    
  end
  
  def index
    @context = 'users'
    @title = 'People'
    
    @users = current_account.users(:all).order('last_name, first_name')
    render :layout => 'full'
  end

  def show
    @user = User.find(params[:id])
    
    @context = 'dashboard'
    @title = @user.name_or_email
  end
end
