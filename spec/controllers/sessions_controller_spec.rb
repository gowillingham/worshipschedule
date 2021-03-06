require 'spec_helper'

describe SessionsController do
  render_views
  
  describe "GET 'new'" do
    
    it "should be successful" do
      get 'new'
      response.should be_success
    end 
    
    it "should have the right title" do
      get :new
      response.should have_selector("title", :content => "sign in")
    end
    
    it "should have forgot password link" do
      get 'new'
      response.should have_selector("a", :content => 'I forgot my email or password')
    end
  end
  
  describe "POST 'create'" do
    
    describe "invalid signin" do
      
      before(:each) do
        @attr = { :email => 'example@email.com', :password => 'invalid' }
      end
      
      it "should re-render the new page" do
        post :create, :session => @attr
        response.should render_template('new')
      end
      
      it "should have the right title" do
        post :create, :session => @attr
        response.should have_selector("title", :content => 'sign in')
      end
      
      it "should have the right flash.now message" do
        post :create, :session => @attr
        flash.now[:error] =~ /invalid/i
      end
    end
    
    describe "with valid email and password" do
      
       before(:each) do
        @user = Factory(:user)
        @attr = { :email => @user.email, :password => @user.password }
        
        @account = Factory(:account, :name => 'First account')
        @another_account = Factory(:account, :name => 'Another account')
       end
       
       it "should sign the user in" do
         post :create, :session => @attr
         controller.current_user.should == @user
         controller.should be_signed_in
       end
       
       it "should redirect to sessions/accounts page for multiple accountships" do
         @user.accounts << @account
         @user.accounts << @another_account
         post :create, :session => @attr
         response.should redirect_to(sessions_accounts_path)
       end
       
       it "should set the current_account for singular accountships" do
         @user.accounts << @account
         post :create, :session => @attr
         controller.current_account.should == @account
       end
       
       it "should redirect to the user show page for singular accountships" do
         @user.accounts << @account
         post :create, :session => @attr
         response.should redirect_to(user_path controller.current_user)
       end
       
       it "should redirect to sessions/accounts page for a user with no accounts" do
         @user.accounts.clear
         post :create, :session => @attr
         response.should redirect_to(sessions_accounts_path)
       end
       
       it "should have the right flash message" do
         post :create, :session => @attr
         flash[:success] =~ /welcome/i
       end
    end
  end
  
  describe "DELETE 'destroy'" do
    
    it "it should sign a user out" do
      signin_user Factory(:user)
      delete :destroy
      controller.should_not be_signed_in
      response.should redirect_to(signin_path)
      flash[:success] =~ /signed out/i
    end
  end
  
  describe "accounts listing" do
    
    it "should have a list of account links belonging to the user" do
      user = Factory(:user)
      signin_user user
      
      @account = Factory(:account)
      @another_account = Factory(:account, :name => 'Another church')
      user.accounts << @account
      user.accounts << @another_account
      
      get :accounts
      response.should have_selector('a', :content => @account.name)
      response.should have_selector('a', :content => @another_account.name)
    end
  end
  
  describe "POST 'set_accounts'" do
    
    before(:each) do
      @user = Factory(:user)
      @account = Factory(:account)
      @user.accounts << @account
      signin_user @user
    end
    
    it "should set the current_account" do
      post :set_account, :id => @account.id
      user = assigns(:user)
      @request.session[:account_id].should == @account.id
      controller.current_account.should == @account
    end
    
    it "should redirect to current_user show" do
      post :set_account, :id => @account.id
      response.should redirect_to(user_path(controller.current_user))
    end
  end
end
