require 'spec_helper'

describe UsersController do
  render_views
  
  before(:each) do
    @signed_in_user = Factory(:user)
    @account = Factory(:account)
    @signed_in_user.accounts << @account
    
    signin_user @signed_in_user
    controller.set_session_account(@account)
  end
  
  describe "GET 'show'" do
    
    before(:each) do
      @user = Factory(:user, :email => Factory.next(:email))
    end
    
    it "should be successful" do
      get :show, :id => @user
      response.should be_success
    end
    
    it "should find the right user" do
      get :show, :id => @user
      assigns(:user).should == @user
    end
  end

  describe "GET 'new'" do
    it "should be successful" do
      get 'new'
      response.should be_success
    end
    
    it "should not allow access if session has timed out" do
      @request.session[:starts] = (Time.now.utc - LOGIN_SESSION_LENGTH - 1.minute)
      get :new
      response.should redirect_to(signin_path)
    end
  end
  
  describe "POST 'create'" do
    
    describe "failure" do
      
      before(:each) do
        @attr = {
          :first_name => '',
          :last_name => '',
          :email => ''
        }
      end
      
      it "should not create a user" do
        lambda do
          post :create, :user => @attr
        end.should_not change(User, :count)
      end
      
      it "should render the new page" do
        post :create, :user => @attr
        response.should render_template('new')
      end
    end
    
    describe "success" do
      
      before(:each) do
        @attr = {
          :first_name => 'Stephen',
          :last_name => 'Willingham',
          :email => 'gowillingham@gmail.com'
        }
      end
      
      it "should create a user if the user doesn't already exist" do
        lambda do
          post :create, :user => @attr
        end.should change(User, :count).by(1)
      end
      
      it "should not create the user if the user already exists" do
        @existing_user = Factory(:user, :email => 'gowillingham@gmail.com')
        lambda do
          post :create, :user => @attr
        end.should change(User, :count).by(0)
      end
      
      it "should add the user to the current_account if the user already exists" do
        @existing_user = Factory(:user, :email => 'gowillingham@gmail.com')
        post :create, :user => @attr
        @existing_user.accounts(@account).exists?.should be_true
      end
      
      it "should not add user to the current account if they exist but already belong to the current account" do
        @existing_user = Factory(:user, :email => 'gowillingham@gmail.com')
        @existing_user.accounts << @account

        post :create, :user => @attr
        @existing_user.accounts.size.should == 1
        response.should render_template('new')
        flash[:error] =~ /already belongs/i
      end
      
      it "should redirect to the user index page" do
        post :create, :user => @attr
        response.should redirect_to(users_path)
      end
      
      it "should have a welcome message" do
        post :create, :user => @attr
        flash[:success] =~ /success/i
      end
      
      it "should add a new user to the current account" do
        post :create, :user => @attr
        user = assigns(:user)
        user.accounts(@account).exists?.should be_true
      end
      
      it "should send a welcome email to the user with credentials"
    end
  end
  
  describe "GET 'edit'" do
    
    before(:each) do
      @user = Factory(:user, :email => Factory.next(:email))
    end
    
    it "should be successful" do
        get :edit, :id => @user.id
        response.should be_success
    end
    
    it "should redirect to signin page when not signed in" do
      controller.sign_out
      get :edit, :id => @user.id
      response.should redirect_to signin_path
    end
    
    describe "when the user to be edited is not the current user" do
      
      it "should show link to reset password feature" do
        get :edit, :id => @user.id
        response.should have_selector("a", :content => 'instructions to choose a new password')
      end
    end
    
    describe "when the user to be edited is the current user" do
      
      it "should display a link to edit the password"
      it "should allow edit of first and last name"
      it "should allow edit of email address if password is provided"
      it "should update the user given valid attributes"
    end
  end
  
  describe "GET 'index'" do
    
    describe "when authenticated" do
      
      before(:each) do
        @user_with_name = Factory(:user, :email => Factory.next(:email), :first_name => 'next', :last_name => 'user')
        @user_with_only_email = Factory(:user, :email => Factory.next(:email))
        @account.users << @user_with_name
        @account.users << @user_with_only_email
      end
      
      it "should be successful" do
        get :index
        response.should be_successful
      end
      
      it "should display the email or name of users belonging to the account" do
        get :index
        response.should have_selector("h4", :content => @user_with_name.name)
        response.should have_selector("a", :content => @user_with_only_email.email)
        response.should have_selector("h4", :content => @signed_in_user.name)
        response.should have_selector("a", :content => @signed_in_user.email)
      end
      
      it "should not return users who only belong to another account" do
        @incorrect_account = Factory(:account, :name => 'Incorrect church')
        @incorrect_user = Factory(:user, :email => Factory.next(:email), :first_name => 'another', :last_name => 'user')
        @incorrect_account.users << @incorrect_user
        response.should_not have_selector("a", :content => @incorrect_user.name_or_email)
      end
    end
    
    describe "when not authenticated" do
      
      it "should redirect to signin page" do
        controller.sign_out
        get :index
        response.should redirect_to signin_path
      end
    end
  end
end
