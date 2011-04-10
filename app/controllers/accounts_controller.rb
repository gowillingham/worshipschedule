class AccountsController < ApplicationController
  skip_before_filter :authenticate, :only => [:new, :create]
  
  def new
    @title = "New account"
    @account = Account.new
  end

  def create
    @account = Account.new(:name => params[:name])
    
    if params[:email].blank?
      @title = 'New'
      flash[:error] = "We'll need your email address to create a #{APP_NAME} account for you!"
      
      render 'new'
    else

      # upsert and signin the user ..
      @user = User.find_by_email(params[:email])
      if @user.nil?
        @user = User.create(
          :email => params[:email],
          :password => generate_password
        )
      end
      sign_in @user
      
      @account.save
      flash[:success] = "Ok. Your new account has been created!"
      redirect_to @user
    end
  end

  def show
  end

  def index
  end

  def destroy
  end

end
