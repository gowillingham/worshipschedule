require 'spec_helper'

describe UsersController do
  render_views
  
  before(:each) do
    @signed_in_user = Factory(:user)
    signin_user @signed_in_user
  end
  
  describe "GET 'show'" do
    
    before(:each) do
      @user = Factory(:user)
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
    
    it "should include the user's name" do
      get :show, :id => @user
      response.should have_selector('h1', :content => @user.last_name)
    end
    
    it "should include the user gravatar image" do
      get :show, :id => @user
      response.should have_selector('img', :class => 'gravatar')
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
  end
  
  describe "POST 'create'" do
    
    describe "failure" do
      
      before(:each) do
        @attr = {
          :first_name => '',
          :last_name => '',
          :email => '',
          :password => '',
          :password_confirm => ''
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
          :email => 'gowillingham@gmail.com',
          :password => 'password',
          :password_confirmation => 'password'
        }
      end
      
      it "should create a user" do
        lambda do
          post :create, :user => @attr
          response.should change(User, :count).by(1)
        end
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
end
