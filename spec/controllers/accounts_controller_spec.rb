require 'spec_helper'

describe AccountsController do
  
  before(:each) do
    @user = Factory(:user)
  end

  describe "when not authenticated" do
    
    describe "GET 'new'" do
      it "should be successful" do
        get 'new'
        response.should be_success
      end
    end
  
    describe "POST 'create'" do
      it "should be successful" do
        post 'create'
        response.should be_success
      end
    end
  end
  
  describe "when authenticated" do
    
    before(:each) do
      @signed_in_user = Factory(:user)
      signin_user @signed_in_user
    end
    
    describe "GET 'show'" do
      it "should be successful" do
        get 'show', :id => @user
        response.should be_success
      end
    end
  
    describe "GET 'index'" do
      it "should be successful" do
        get 'index'
        response.should be_success
      end
    end
  
    describe "POST 'destroy'" do
      it "should be successful" do
        post 'destroy', :id => @user
        response.should be_success
      end
    end
  end
end
