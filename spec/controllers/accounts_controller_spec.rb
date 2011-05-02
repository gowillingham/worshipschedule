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
          
          @new_user_attr = {
            :account => { :name => 'Church name'},
            :user => { :email => Factory.next(:email) }
          }
          @existing_user_attr = {
            :account => { :name => 'Church name' },
            :user => { :email => @user.email}
          }
        end
        
        it "should create a new account" do
          lambda do
            post :create, @new_user_attr
          end.should change(Account, :count).by(1)
        end
        
        it "should add an accountship for a new user" do
          lambda do
            post :create, @new_user_attr
          end.should change(Accountship, :count).by(1)
        end
        
        it "should add an accountship for an existing user" do
          lambda do
            post :create, @existing_user_attr
          end.should change(Accountship, :count).by(1)
        end
        
        it "should not create a user if the user already exists" do
          lambda do
            post :create, @existing_user_attr
          end.should change(User, :count).by(0)
        end
        
        it "should associate a new user with the new account" do
          post :create, @new_user_attr
          account = assigns(:account)
          account.users.should include(assigns(:user))
        end
        
        it "should associate an existing user with the new account" do
          post :create, @existing_user_attr
          account = assigns(:account)
          account.users.should include(assigns(:user))
        end
        
        it "should make the user an account administrator" do
          post :create, @new_user_attr
          account = assigns(:account)
          account.accountships.find_by_user_id(assigns(:user)).should be_admin
        end
        
        it "should render signin page for an existing user" do
          post :create, @existing_user_attr
          response.should redirect_to(signin_path)
        end
        
        it "should render the password set page for a new user" do
          post :create, @new_user_attr
          response.should redirect_to(profile_reset_path(assigns(:user).forgot_hash))
        end
      end
      
      describe "failure" do
        
        before(:each) do
          @invalid_user_attr = {
            :account => { :name => '' },
            :user => { :email => '' }
          }
        end
        
        it "should not create the account" do
          lambda do
            post :create, @invalid_user_attr
          end.should change(Account, :count).by(0)
        end
        
        it "should not upsert the user" do
          lambda do
            post :create, @invalid_user_attr
          end.should change(User, :count).by(0)
        end
        
        it "should render the new page" do
          post :create, @invalid_user_attr
          response.should render_template('new')
        end
      end
    end
  end
  
  describe "when authenticated" do
    
    before(:each) do
      @signed_in_user = Factory(:user)
      @account = Factory(:account)
      @signed_in_user.accounts << @account
      
      signin_user @signed_in_user
      controller.set_session_account(@account)
    end
    
    describe "GET 'show'" do
      it "should be successful" do
        get 'show', :id => @account
        response.should be_success
      end
    end
  end
end
