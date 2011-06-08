require 'spec_helper'

describe UsersController do
  render_views
  
  before(:each) do
    @signed_in_user = Factory(:user)
    @account = Factory(:account)
    @signed_in_user.accounts << @account
    
    @accountship = @signed_in_user.accountships.find_by_account_id(@account.id)
    @accountship.admin = true
    @accountship.save
    
    signin_user @signed_in_user
    controller.set_session_account(@account)
  end
  
  describe "when displaying tabs" do
    
    it "should show the correct tabs to regular users" do
      @accountship.admin = false
      @accountship.save
      
      get :show, :id => @signed_in_user
      
      response.should have_selector('ul.tabs li a', :content => 'Dashboard')
      response.should have_selector('ul.tabs li a', :content => 'Churches')
      response.should have_selector('ul.tabs li a', :content => 'Events')
      response.should_not have_selector('ul.tabs li a', :content => 'All people')
      response.should_not have_selector('ul.tabs li a', :content => 'Email')
      response.should_not have_selector('ul.tabs li a', :content => 'Account')
    end
    
    it "should show the correct tabs to admin users" do
      new_owner = Factory(:user, :email => Factory.next(:email))
      @account.owner = new_owner
      @account.save
      
      get :show, :id => @signed_in_user
      
      response.should have_selector('ul.tabs li a', :content => 'Dashboard')
      response.should have_selector('ul.tabs li a', :content => 'Churches')
      response.should have_selector('ul.tabs li a', :content => 'Events')
      response.should have_selector('ul.tabs li a', :content => 'All people')
      response.should have_selector('ul.tabs li a', :content => 'Email')
      response.should_not have_selector('ul.tabs li a', :content => 'Account')
    end
    
    it "should show the correct tabs to the account owner" do
      @account.owner = @signed_in_user
      @account.save
      
      get :show, :id => @signed_in_user
      
      response.should have_selector('ul.tabs li a', :content => 'Account')
    end
  end
  
  describe "PUT 'memberships_for'" do
    
    it "should redirect if not logged in"
    it "should allow account admin"
    it "should redirect non-admin"
    it "should fail to add a user from another account"
    it "should add/remove teams given valid attributes"
  end

  describe "GET 'show'" do
    
    before(:each) do
      @user = Factory(:user, :email => Factory.next(:email))
      @user.accounts << @account
      
      @team = Team.create(
        :name => 'Worship team',
        :account_id => @account.id
      )
      @team_two = Team.create(
        :name => 'Tech team',
        :account_id => @account.id
      )
    end
    
    it "should be successful" do
      get :show, :id => @user
      response.should be_success
    end
    
    it "should find the right user" do
      get :show, :id => @user
      assigns(:user).should == @user
    end
    
    it "should show a new team link to admin user" do
      get :show, :id => @user
      response.should have_selector('a', :content => 'New team')
      response.should have_selector('a', :href => new_team_path)
    end
    
    it "should not show a new team link to non-admin user" do
      @accountship.admin = false
      @accountship.save
      
      get :show, :id => @user
      response.should_not have_selector('a', :content => 'New team')
      response.should_not have_selector('a', :href => new_team_path)
    end
    
    it "should display the member's permissions in the sidebar"
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
        end.should change(User, :count).by(0)
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
    end
  end
  
  describe "GET 'edit'" do
    
    before(:each) do
      @user = Factory(:user, :email => Factory.next(:email))
      @user.accounts << @account

      @team_1 = @account.teams[0]
      @team_2 = @account.teams[1]
      @team_3 = Factory(:team, :account => @account)
      @account.teams << @team_3
      
      @team_1.memberships.create(:user_id => @user.id, :active => true)
      @team_2.memberships.create(:user_id => @user.id, :active => true)
    end

    it "should redirect to signin page when not signed in" do
      controller.sign_out
      get :edit, :id => @user.id
      response.should redirect_to signin_path
    end
    
    it "should redirect for a user who doesn't belong to the current account" do
      @user.accounts.clear
      get :edit, :id => @user.id
      response.should redirect_to(@signed_in_user)
      flash[:error] =~ /don't have permission/i
    end
    
    it "should show listing of permissions" do
      get :edit, :id => @user
      response.should have_selector("ul", :class => 'permissions')
    end
    
    it "should show the list of teams for the current account" do
      get :edit, :id => @user.id
      
      response.should have_selector("li.team", :content => @team_1.name)
      response.should have_selector("li.team", :content => @team_2.name)
      response.should have_selector("li.team", :content => @team_3.name)
    end
      
    it "should show a member's teams in the list as checked" do
      get :edit, :id => @user.id
      response.should have_selector("input[type=checkbox][checked=checked]", :value => @team_1.id.to_s)
      response.should have_selector("input[type=checkbox][checked=checked]", :value => @team_2.id.to_s)
      response.should_not have_selector("input[type=checkbox][checked=checked]", :value => @team_3.id.to_s)
    end
    
    describe "when the logged in user is a not an account admin" do
      
      before(:each) do
        @accountship.admin = false
        @accountship.save
        @membership = @team_1.memberships.create(:user_id => @signed_in_user.id, :admin => true, :active => true)
      end
      
      it "should redirect for user not owned by the logged in (current) user" do
        user_2 = Factory(:user, :email => Factory.next(:email))
        @account.users << user_2
        
        get :edit, :id => user_2
        response.should redirect_to(user_path(@signed_in_user))
        flash[:error] =~ /don't have permission/i
      end
      
      it "should not show submit/cancel for the permissions list" do
        get :edit, :id => @user
        
        response.should_not have_selector(".actions input", :value => 'Update team access')
      end
      
      it "should disable the permissions checkboxes" do
        get :edit, :id => @user

        response.should have_selector("input[type=checkbox][disabled=disabled]", :value => @team_1.id.to_s)
        response.should have_selector("input[type=checkbox][disabled=disabled]", :value => @team_2.id.to_s)
        response.should have_selector("input[type=checkbox][disabled=disabled]", :value => @team_3.id.to_s)
      end
      
      it "should not show destroy user link" do
        get :edit, :id => @user
        response.should_not have_selector("a", :content => "Delete #{@user.name_or_email}")
      end
    end
    
    describe "when the user to be edited is not the current user" do
      
      it "should show a link to destroy the user" do
        get :edit, :id => @user.id
        response.should have_selector("a", :content => "Delete #{@user.name_or_email}")
      end
      
      it "should show link to reset password feature" do
        get :edit, :id => @user.id
        response.should have_selector("a", :content => 'instructions to choose a new password')
      end
    end
    
    describe "when the user to be edited is the current user" do
      
      it "should display a link to edit the user's profile information" do
        get :edit, :id => @signed_in_user
        response.should have_selector("a", :content => "Edit your personal information")
      end
      
      it "should not display a link to delete the user" do
        get :edit, :id => @signed_in_user
        response.should_not have_selector("a", :content => "Delete #{@user.name_or_email}")
      end
    end
    
  end
  
  describe "PUT 'update'" do
    
    before(:each) do
      @user_to_edit = Factory(:user, :email => Factory.next(:email), :first_name => 'First', :last_name => 'Last')
      @user_to_edit.accounts << @account
    end
    
    it "should redirect to signin when not signed in" do
      controller.sign_out
      put :update, :id => @user_to_edit.id, :user => @user_to_edit
      response.should redirect_to(signin_path)
    end
    
    it "should not allow update for a user who doesn't belong to the current account" do
      @user_to_edit.accounts.clear
      put :update, :id => @user_to_edit.id, :user => @user_to_edit
      response.should redirect_to(@signed_in_user)
      flash[:error] =~ /don't have permission/i
    end
    
    describe "when the user to be edited is not the current user" do
      
      before(:each) do
        @attr = {
          :office_phone => '888-999-7777',
          :office_phone_ext => '2255',
          :home_phone => '888 999 7777',
          :mobile_phone => '888.999.7777'
        }
      end
  
      it "should not allow update if the current user is not an admin for the current account" do
        @accountship.admin = false
        @accountship.save
        put :update, :id => @user_to_edit.id, :user => @user_to_edit
        response.should redirect_to(@signed_in_user)
        flash[:error] =~ /don't have permission/i
      end
    
      it "should update the user given valid attributes" do
        put :update, :id => @user_to_edit.id, :user => @attr
        user = User.find_by_id(@user_to_edit.id)
        
        user.office_phone.should == @attr[:office_phone]
        user.office_phone_ext.should == @attr[:office_phone_ext]
        user.mobile_phone.should == @attr[:mobile_phone]
        user.home_phone.should == @attr[:home_phone]
      end
      
      it "should not update the user given invalid attributes" do
        @attr = { :office_phone => 'booger' }
        
        put :update, :id => @user_to_edit, :user => @attr
        response.should render_template('edit')
        response.should have_selector("div#error_explanation")
      end
      
      it "should not change email, first_name, or last_name" do
        put :update, :id => @user_to_edit.id, :user => @attr
        user = User.find_by_id(@user_to_edit.id)
        
        user.email.should == @user_to_edit.email
        user.first_name.should == @user_to_edit.first_name
        user.last_name.should == @user_to_edit.last_name
      end
      
      it "should render the edit page with a flash message" do
        put :update, :id => @user_to_edit.id, :user => @attr
        response.should redirect_to edit_user_path(@user_to_edit)
        flash[:success].should =~ /the settings for this person have been saved successfully/i
      end
    end
    
    describe "when the user to be edited is the current user" do
      
      before(:each) do
        @attr = {
          :first_name => 'New_first_name',
          :last_name => 'New_last_name',
          :office_phone => '888-999-7777',
          :office_phone_ext => '2255',
          :home_phone => '888 999 7777',
          :mobile_phone => '888.999.7777'
        }
      end
      
      it "should update the contact details given valid attributes" do
        put :update, :id => @signed_in_user, :user => @attr
        user = User.find_by_id(@signed_in_user.id)
        
        user.office_phone.should == @attr[:office_phone]
        user.office_phone_ext.should == @attr[:office_phone_ext]
        user.mobile_phone.should == @attr[:mobile_phone]
        user.home_phone.should == @attr[:home_phone]
        user.first_name == @attr[:first_name]
        user.last_name == @attr[:last_name]
      end
      
      it "should re-render the edit page with a flash confirmation message" do
        put :update, :id => @signed_in_user, :user => @attr
        response.should redirect_to(edit_user_path @signed_in_user)
        flash[:success] =~ /saved successfully/i
      end
    end
  end
  
  describe "GET 'index'" do
    
    describe "when authenticated" do
      
      before(:each) do
        @user_with_name = Factory(:user, :email => Factory.next(:email), :first_name => 'next', :last_name => 'user')
        @user_with_only_email = Factory(:user, :first_name => '', :last_name => '', :email => Factory.next(:email))
        @account.users << @user_with_name
        @account.users << @user_with_only_email
      end
      
      it "should be successful" do
        get :index
        response.should be_successful
      end
      
      it "should have a link to the administrator list" do
        get :index
        response.should have_selector('a', :content => 'administrator list')
      end
      
      it "should display the email or name of users belonging to the account" do
        get :index
        response.should have_selector("h4", :content => @user_with_name.name)
        response.should have_selector("a", :content => @user_with_only_email.email)
        response.should have_selector("h4", :content => @signed_in_user.name)
        response.should have_selector("a", :content => @signed_in_user.email)
      end
      
      it "should display the users in non-case sensitive alphabetical order" do
        user_aa = Factory(:user, :last_name => 'aa', :first_name => 'first', :email => Factory.next(:email))
        user_Ab = Factory(:user, :last_name => 'aB', :first_name => 'first', :email => Factory.next(:email))
        user_ZZ = Factory(:user, :last_name => 'ZZ', :first_name => 'first', :email => Factory.next(:email))
        @account.users << user_aa
        @account.users << user_Ab
        @account.users << user_ZZ
        
        get :index
        users = assigns(:users)
        users.first.should eq(user_aa)
        users.last.should eq(user_ZZ)
      end
      
      it "should order by email if the name is missing" do
        user_aa = Factory(:user, :last_name => '', :first_name => 'first', :email => 'aa@aa.com')
        user_bb = Factory(:user, :last_name => 'bb', :first_name => 'first', :email => 'bb@bb.com')
        user_zz = Factory(:user, :last_name => '', :first_name => 'first', :email => 'zz@zz.com')
        user_aa.accounts << @account
        user_bb.accounts << @account
        user_zz.accounts << @account
        
        get :index
        users = assigns(:users)
        users.first.should eq(user_aa)
        users.last.should eq(user_zz)
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
  
  describe "DELETE 'destroy'" do
    
    before(:each) do
      @user = Factory(:user, :email => Factory.next(:email))
      @another_account = Factory(:account)
      @user.accounts << @account
    end
    
    it "should not destroy the user if they have multiple accounts" do
      @user.accounts << @another_account
      lambda do
        delete :destroy, :id => @user
      end.should change(User, :count).by(0)
    end
    
    it "should only remove the user from the current account" do
      @user.accounts << @another_account
      delete :destroy, :id => @user
      
      user = assigns(:user)
      user.accounts.exists?(@another_account).should be_true
    end
    
    it "should delete the user if the current account is the user's only account" do
      lambda do
        delete :destroy, :id => @user
      end.should change(User, :count).by(-1)
    end

    it "should redirect to the index page" do
      delete :destroy, :id => @user
      response.should redirect_to users_path
    end
    
    it "should not remove the user if the current user is not an admin" do
      accountship = @signed_in_user.accountships.find_by_account_id(@account.id)
      accountship.toggle(:admin).save
      
      lambda do
        delete :destroy, :id => @user
      end.should change(User, :count).by(0)
    end
    
    it "should redirect to user show with flash message if the current user is not an admin" do
      accountship = @signed_in_user.accountships.find_by_account_id(@account.id)
      accountship.toggle(:admin).save

      delete :destroy, :id => @user
      response.should redirect_to(user_path @signed_in_user)
      flash[:error] =~ /don't have permission/i
    end

    it "should not remove the current user account" do
      lambda do
        delete :destroy, :id => @signed_in_user
      end.should change(User, :count).by(0)
    end
    
    it "should redirect to user#show with flash message if the target user is the current user" do
      delete :destroy, :id => @signed_in_user
      response.should redirect_to(edit_user_path @signed_in_user)
      flash[:error] =~ /cannot remove yourself/i
    end
    
    it "should not remove the user if the current user is not signed in" do
      controller.sign_out
      lambda do
        delete :destroy, :id => @user
      end.should change(User, :count).by(0)
    end
  end

  describe "POST 'send_reset" do
    
    before(:each) do
      @user = Factory(:user, :email => Factory.next(:email))
    end
    
    it "should redirect to edit_user_path with a flash message" do
      get :send_reset, :id => @user
      response.should redirect_to(edit_user_path(@user))
    end
  end
end
