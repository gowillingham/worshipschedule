class AccountsController < ApplicationController
  skip_before_filter :authenticate, :only => [:new, :create]
  skip_before_filter :check_account, :except => [:show]
  
  def new
    @title = "New account"
    @account = Account.new
    render 'new', :layout => 'signin'
  end

  def create
    @account = Account.new(params[:account])
    
    if params[:user][:email].blank?
      @title = 'New'
      flash[:error] = "We'll need your email address to create a #{APP_NAME} account for your church!"
      
      render 'new', :layout => 'signin'
    else

      @account.save
      
      # upsert and signin the user ..
      @user = User.find(:first, :conditions => ["lower(email) = ?", params[:user][:email].downcase])
      if @user.nil?
        @user = User.new(:email => params[:user][:email])
        @user.validate_password = false
        @user.save
      end
      
      # associate and sign_in the user ..
      @account.users << @user
      @user.accountships.find_by_account_id(@account).toggle!(:admin)
      sign_in @user
      
      flash[:success] = "Ok. Your new account has been created!"
      redirect_to @user
    end
  end

  def show

  end
end
