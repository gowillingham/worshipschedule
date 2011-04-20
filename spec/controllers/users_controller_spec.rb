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
    
    it "should have the right title" do
      get :show, :id => @user
      response.should have_selector('title', :content => @user.last_name)
    end
  end

  describe "GET 'new'" do
    it "should be successful" do
      get 'new'
      response.should be_success
    end
    
    it "should have the right title" do
      get :new
      response.should have_selector('title', :content => 'New')
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
      
      it "should have the correct title" do
        post :create, :user => @attr
        response.should have_selector('title', :content => 'New')
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
      
      it "should create a user" do
        lambda do
          post :create, :user => @attr
        end.should change(User, :count).by(1)
      end
      
      it "should redirect to the user show page" do
        post :create, :user => @attr
        response.should redirect_to(user_path(assigns(:user)))
      end
      
      it "should have a welcome message" do
        post :create, :user => @attr
        flash[:success] =~ /success/i
      end
    end
  end
  
  describe "GET 'index'" do
    
    describe "when authenticated" do
      
      before(:each) do
        @next_user = Factory(:user, :email => Factory.next(:email), :first_name => 'next', :last_name => 'user')
        @another_user = Factory(:user, :email => Factory.next(:email), :first_name => 'another', :last_name => 'user')
        @account.users << @next_user
        @account.users << @another_user
      end
      
      it "should be successful" do
        get :index
        response.should be_successful
      end
      
      it "should return a list of users belonging to the account" do
        get :index
        response.should have_selector("a", :content => @next_user.name_or_email)
        response.should have_selector("a", :content => @another_user.name_or_email)
        response.should have_selector("a", :content => @signed_in_user.name_or_email)
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
