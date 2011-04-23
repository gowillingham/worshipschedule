class UsersController < ApplicationController
  before_filter :require_account_admin, :except => :show
  
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
          flash[:error] = "That email address already belongs to a person with your church. "
          @title = 'New'
          render 'new'
        else
          existing_user.accounts << current_account
          flash[:success] = "#{existing_user.name_or_email} was added to your church! "
          redirect_to users_path
        end
      end

    else
      @title = "All people"
      render 'new'
    end
  end
  
  def new
    @title = 'All people'
    @user = User.new
    @context = 'users'
  end
  
  def edit
    @user = User.find(params[:id])
    unless current_account.users.exists? @user
      flash[:error] = "You don't have permission to access that person. "
      redirect_to current_user
    end 

    @title = "All people"
    @context = 'users'
  end
  
  def update
    @user = User.find(params[:id])
    
    if current_account.users.exists? @user
      if @user.update_attributes(params[:user])
        flash[:success] = "The settings for this person have been saved successfully. "
        redirect_to edit_user_path @user
      else
        @title = "All people"
        @context = "users"
        render 'edit'
      end
    else
      flash[:error] = "You don't have permission to access that person. "
      redirect_to current_user
    end
  end
  
  def index
    @context = 'users'
    @title = 'All people'
    
    @users = current_account.users(:all, :includes => :accountships).order('last_name, first_name, email')
    render :layout => 'full'
  end

  def show
    @user = User.find(params[:id])
    unless current_account.users.exists? @user
      flash[:error] = "You don't have permission to access that person. "
      redirect_to current_user
    end 

    @context = 'dashboard'
    @title = 'Dashboard'
  end
  
  def destroy
    
  end
end
