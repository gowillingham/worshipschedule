require 'spec_helper'

describe AccountsController do
  render_views
  
  before(:each) do
    @user = Factory(:user)

    @signed_in_user = Factory(:user, :email => Factory.next(:email))
    @account = Factory(:account)
    
    @signed_in_user.accounts << @account
    
    signin_user @signed_in_user
    controller.set_session_account(@account)
  end
  
  describe "DELETE 'destroy'" do
    
    it "should not allow unauthenticated access" do
      controller.sign_out
      post :destroy, :id => @account
      
      response.should redirect_to(signin_path)
    end
    
    it "should not allow access to non-owner" do
      post :destroy, :id => @account
      
      response.should redirect_to(@signed_in_user)
      flash[:error] =~ /only the account owner/i
    end
    
    it "should delete dependent objects"
    
    describe "for account owner" do
      
      before(:each) do
        @account.owner = @signed_in_user
        @account.save
      end
      
      it "should remove the account" do
        lambda do
          post :destroy, :id => @account
        end.should change(Account, :count).by(-1)
      end
      
      it "should sign out and redirect to '/'" do
        post :destroy, :id => @account
        
        response.should redirect_to(root_path)
        controller.should_not be_signed_in
        flash[:notice] =~ /sorry to see you go/i
      end
    end
  end
  
  describe "PUT 'update'" do
    
    before(:each) do
      @accountship = @signed_in_user.accountships.find_by_account_id(@account.id)
      @accountship.admin = true
      @accountship.save
    end
    
    it "should not allow unauthenticated access" do
      controller.sign_out
      put :update, :id => @account
      
      response.should redirect_to(signin_path)
    end
    
    it "should not allow access to non-owner" do
      put :update, :id => @account
      
      response.should redirect_to(@signed_in_user)
      flash[:error] =~ /only the account owner/i
    end
    
    describe "for account owner" do
      
      before(:each) do
        @account.owner = @signed_in_user
        @account.save
      end
      
      it "should change the name given valid attributes" do
        put :update, :id => @account, :account => { :name => 'The new name' }
        
        Account.find(@account.id).name.should eq('The new name')
      end
      
      it "should not change the name given invalid attributes" do
        put :update, :id => @account, :account => { :name => '' }
        
        Account.find(@account.id).name.should eq(@account.name)
        response.should render_template('edit')
      end
      
      it "should redirect to accounts#edit on success" do
        put :update, :id => @account, :account => { :name => 'The new name' }
        
        response.should redirect_to(edit_account_path(@account))
        flash[:success] =~ /settings were changed/i
      end
    end
  end
  
  describe "PUT 'owner'" do
    
    it "should not allow unauthenticated access" do
      controller.sign_out
      put :owner, :id => @account
      
      response.should redirect_to(signin_path)
    end
    
    it "should not allow access to non-owner" do
      put :owner, :id => @account
      
      response.should redirect_to(@signed_in_user)
      flash[:error] =~ /only the account owner/i
    end
    
    describe "for account owner" do
 
      before(:each) do
        @account.owner = @signed_in_user
        @account.save
      end
      
      it "should not change the owner to a non-account user" do
        orphan_user = Factory(:user, :email => Factory.next(:email))
        put :owner, :id => @account, :account => { :owner_id => orphan_user.id }
        
        Account.find(@account.id).owner.should_not eq(orphan_user)
        flash[:error] =~ /must assign a person from your account/i
      end
      
      it "should set a new owner given valid attributes" do
        new_owner = Factory(:user, :email => Factory.next(:email))
        @account.users << new_owner
        put :owner, :id => @account, :account => { :owner_id => new_owner.id }
        
        Account.find(@account.id).owner.should eq(new_owner)
      end
      
      it "should redirect to user#show on success" do
        new_owner = Factory(:user, :email => Factory.next(:email))
        @account.users << new_owner
        put :owner, :id => @account, :account => { :owner_id => new_owner.id }
        
        response.should redirect_to(@signed_in_user)
        flash[:success] =~ /new owner was assigned/i
      end
    end
  end
  
  describe "GET 'edit'" do
    
    before(:each) do
      
      @account.owner = @signed_in_user
      @account.save
    end
    
    it "should not allow unauthenticated access" do
      controller.sign_out
      get :edit, :id => @account
      
      response.should redirect_to(signin_path)
    end
    
    it "should only allow access to account owner" do
      different_owner = Factory(:user, :email => Factory.next(:email))
      @account.owner = different_owner
      @account.save
      get :edit, :id => @account
      
      response.should redirect_to(@signed_in_user)
      flash[:error] =~ /only the account owner/i
    end
    
    it "should display a delete link" do
      get :edit, :id => @account
      response.should have_selector("a", :content => "I understand - please cancel my account")
    end
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
        
        it "should make the user the account owner" do
          post :create, @new_user_attr
          assigns(:account).owner.should eq(assigns(:user))
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
      @admin = Factory(:user, :email => Factory.next(:email))
      @not_admin = Factory(:user, :email => Factory.next(:email))
      @owner = Factory(:user, :email => Factory.next(:email))

      @admin_accountship = @admin.accountships.create(:account_id => @account, :admin => true)
      @not_admin_accountship = @not_admin.accountships.create(:account_id => @account, :admin => false)
      @owner_accountship = @owner.accountships.create(:account_id => @account, :admin => true)
      
      @signed_in_user_accountship = Accountship.where('account_id = ? AND user_id = ?', @account.id, @signed_in_user.id).first
      @signed_in_user_accountship.admin = true
      @signed_in_user_accountship.save
      
      @account.owner = @owner
      @account.save
    end
    
    describe "PUT 'update_admins" do
      it "should not allow access to non-authenticated users"  do
        controller.sign_out
        put :update_admins, :id => @account, :accountship_ids => [@not_admin_accountship.id.to_s]
        response.should redirect_to(signin_path)
      end
      
      it "should not allow access to non-admin users" do
        controller.sign_out
        signin_user @not_admin
        controller.set_session_account(@account)

        put :update_admins, :id => @account, :accountship_ids => [@not_admin_accountship.id.to_s]
        response.should redirect_to(@not_admin)
        flash[:error] =~ /permission/i
      end
      
      describe "when passed a list of accountship identifiers" do
        
        it "should redirect to accounts#admins" do
          put :update_admins, :id => @account, :accountship_ids => [@not_admin_accountship.id.to_s, @admin_accountship.id.to_s]
          response.should redirect_to(users_url)
        end
        
        it "should assign admin to users in the list" do
          put :update_admins, :id => @account.id, :accountship_ids => [@not_admin_accountship.id.to_s, @admin_accountship.id.to_s]

          Accountship.find(@not_admin_accountship.id).admin.should be_true
          Accountship.find(@admin_accountship.id).admin.should be_true
        end
        
        it "should un-assign admin to users who are admin but not in the list" do
          put :update_admins, :id => @account.id, :accountship_ids => [@not_admin_accountship.id.to_s]
          
          Accountship.find(@admin_accountship.id).admin.should_not be_true
        end
        
        it "should not un-assign the account owner or logged in user" do
          put :update_admins, :id => @account.id, :accountship_ids => [@not_admin_accountship.id.to_s]
          
          Accountship.find(@owner_accountship.id).admin.should be_true
          Accountship.find(@signed_in_user_accountship.id).admin.should be_true
        end
      end
    end
    
    describe "GET 'admins'" do
      
      it "should not allow access to non-authenticated users" do
        controller.sign_out
        get :admins, :id => @account
        response.should redirect_to(signin_path)
      end
      
      it "should not allow access to non-admin users" do
        controller.sign_out
        signin_user @not_admin
        controller.set_session_account(@account)
        
        get :admins, :id => @account
        response.should redirect_to(@not_admin)
        flash[:error] =~ /permission/i
      end
      
      it "should allow access to admin users" do
        get :admins, :id => @account
        response.should render_template('admins')
      end

      it "should show admin users as checked" do
        get :admins, :id => @account
        response.should have_selector("input[type=checkbox][checked=checked]", :value => @admin_accountship.id.to_s)
      end
      
      it "should show non-admin users as unchecked" do
        get :admins, :id => @account
        response.should_not have_selector("input[type=checkbox][checked=checked]", :value => @not_admin_accountship.id.to_s)
        response.should have_selector("input[type=checkbox]", :value => @not_admin_accountship.id.to_s)
      end
    end
    
    describe "GET 'show'" do
      it "should be successful" do
        get 'show', :id => @account
        response.should be_success
      end
    end
    
  
  
  end
end
