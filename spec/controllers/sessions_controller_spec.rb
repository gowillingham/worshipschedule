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
       end
       
       it "should sign the user in" do
         post :create, :session => @attr
         controller.current_user.should == @user
         controller.should be_signed_in
       end
       
       it "should redirect to the user show page" do
         post :create, :session => @attr
         response.should redirect_to(user_path(@user))
       end
       
       it "should have the right flash message" do
         post :create, :session => @attr
         flash[:success] =~ /welcome/i
       end
    end
  end
  
  describe "DELETE 'destroy'" do
    
    it "it should sign a user out" do
      test_signin_user(Factory(:user))
      delete :destroy
      controller.should_not be_signed_in
      response.should redirect_to(root_path)
      flash[:success] =~ /signed out/i
    end
  end
end
