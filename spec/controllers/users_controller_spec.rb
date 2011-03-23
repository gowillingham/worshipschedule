require 'spec_helper'

describe UsersController do
  render_views
  
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
end
