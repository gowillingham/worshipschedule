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
      
      describe "success" do
        
        before(:each) do
          @name = 'Church name'
          @email = Factory.next(:email)
        end
        
        it "should create a new account" do
          lambda do
            post :create, { :name => @name, :email => @email }
          end.should change(Account, :count).by(1)
        end
        
        it "should create or upsert the user creating the account" do
          lambda do
            post :create, { :name => @name, :email => @email }
          end.should change(User, :count).by(1)
        end
        
        it "should signin the user creating the account" do
          post :create, { :name => @name, :email => @email }
          @request.session[:user_id].should_not be_nil
        end
        
        it "should associate the user with the new account"
        it "should make the user an account administrator"
        
        it "should render the user#show page" do
          post :create, { :name => @name, :email => @email }
          response.should redirect_to(user_path(assigns(:user)))
        end
      end
      
      describe "failure" do
        
        before(:each) do
          @attr = {
            :name => '',
            :email => ''
          }
        end
        
        it "should not create the account" do
          lambda do
            post :create, { :name => @name, :email => @email }
          end.should change(Account, :count).by(0)
        end
        
        it "should not upsert the user" do
          lambda do
            post :create, { :name => @name, :email => @email }
          end.should change(User, :count).by(0)
        end
        
        it "should render the new page" do
          post :create, { :name => @name, :email => @email }
          response.should render_template('new')
        end

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
