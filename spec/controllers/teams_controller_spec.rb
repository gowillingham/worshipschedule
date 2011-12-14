require 'spec_helper'

describe TeamsController do
  render_views

  before(:each) do
    @signed_in_user = Factory(:user, :email => Factory.next(:email))
    @account = Factory(:account)
    @signed_in_user.accounts << @account
    
    signin_user @signed_in_user
    controller.set_session_account(@account)
  end
  
  describe "GET 'admins'" do
    
    before(:each) do
      @team = @account.teams[0]
    end
    
    it "should not allow unauthorized access" do
      controller.sign_out
      get :admins, :id => @team
      response.should redirect_to(signin_path)
    end
    
    it "should re-direct for non-team or account admin" do
      get :admins, :id => @team
      response.should redirect_to(@signed_in_user)
    end
    
    describe "for admin user" do
      
      before(:each) do
        @accountship = @signed_in_user.accountships.where('account_id = ?', @account.id).first
        @accountship.admin = true
        @accountship.save
        
        @membership = @team.memberships.create(:user_id => @signed_in_user.id, :admin => true)
        
        @user_1 = Factory(:user, :last_name => 'user_1', :email => Factory.next(:email))
        @user_2 = Factory(:user, :last_name => 'user_2', :email => Factory.next(:email))
        @user_3 = Factory(:user, :last_name => 'user_3', :email => Factory.next(:email))
        @user_1.accounts << @account
        @user_2.accounts << @account
        @user_3.accounts << @account
        
        @membership_1 = @team.memberships.create(:user_id => @user_1.id)
        @membership_2 = @team.memberships.create(:user_id => @user_2.id)
        @membership_3 = @team.memberships.create(:user_id => @user_3.id)
        
      end
      
      it "should allow account admin who isn't team admin" do
        @membership.admin = false
        @membership.save
         
        get :admins, :id => @team
        response.should render_template(:admins)
      end
      
      it "should allow team admin who isn't account admin" do
        @accountship.admin = false
        @accountship.save        
        
        get :admins, :id => @team
        response.should render_template(:admins)
      end
      
      it "should show a listing of members" do
        get :admins, :id => @team
        
        response.should have_selector("label", :content => @signed_in_user.first_name + ' ' + @signed_in_user.last_name)
        response.should have_selector("label", :content => @user_1.first_name + ' ' + @user_1.last_name)
        response.should have_selector("label", :content => @user_2.first_name + ' ' + @user_2.last_name)
        response.should have_selector("label", :content => @user_3.first_name + ' ' + @user_3.last_name)
      end
      
      it "should show team administrators in the list as checked and non-admins as unchecked" do
        @membership.admin = false
        @membership.save
        @membership_2.admin = true
        @membership_2.save
        
        get :admins, :id => @team
        
        response.should_not have_selector("input[type=checkbox][checked=checked]", :value => @signed_in_user.id.to_s)        
        response.should have_selector("input[type=checkbox][checked=checked]", :value => @user_2.id.to_s)        
        response.should_not have_selector("input[type=checkbox][checked=checked]", :value => @user_3.id.to_s)        
      end
    end
  end
  
  describe "PUT 'update_admins'" do
    
    before(:each) do
      @team = @account.teams[0]
    end
    
    it "should not allow unauthorized access" do
      controller.sign_out
      put :update_admins, :id => @team
      response.should redirect_to(signin_path)
    end
    
    it "should re-direct for non-team or account admin" do
      put :update_admins, :id => @team
      response.should redirect_to(@signed_in_user)
    end
    
    describe "for admin" do
      
      before(:each) do
        @accountship = @signed_in_user.accountships.where('account_id = ?', @account.id).first
        @accountship.admin = true
        @accountship.save
        
        @membership = @team.memberships.create(:user => @signed_in_user)

        @user_1 = Factory(:user, :last_name => 'user_1', :email => Factory.next(:email))
        @user_2 = Factory(:user, :last_name => 'user_2', :email => Factory.next(:email))
        @user_3 = Factory(:user, :last_name => 'user_3', :email => Factory.next(:email))
        @user_1.accounts << @account
        @user_2.accounts << @account
        @user_3.accounts << @account
        
        @membership_1 = @team.memberships.create(:user_id => @user_1.id)
        @membership_2 = @team.memberships.create(:user_id => @user_2.id)
        @membership_3 = @team.memberships.create(:user_id => @user_3.id)
      end
      
      it "should allow account admin" do
        put :update_admins, :id => @team
        
        response.should redirect_to edit_team_path(@team)
      end
      
      it "should allow team admin that is not account admin" do
        @accountship.admin = false
        @accountship.save
        @membership.admin = true
        @membership.save

        put :update_admins, :id => @team
      end 
      
      it "should update the admin status of a list of team members" do 
          membership_id = [@membership_1.user_id.to_s, @membership_3.user_id.to_s]
          
          put :update_admins, :id => @team, :membership_id => membership_id
          
          Membership.where(:user_id => @membership_1.user_id, :team_id => @team.id).first.admin.should be_true
          Membership.where(:user_id => @membership_2.user_id, :team_id => @team.id).first.admin.should_not be_true
          Membership.where(:user_id => @membership_3.user_id, :team_id => @team.id).first.admin.should be_true
      end 
      it "should not allow user to remove self from admin role"
    
      it "should redirect to team settings page teams/id/edit on success" do
      end
    end 
  end
  
  describe "PUT 'remove_all'" do
    
    before(:each) do
      @team = @account.teams[0]
    end
    
    it "should not allow unauthenticated user" do
      controller.sign_out
      put :remove_all, :id => @team
      response.should redirect_to(signin_path)
    end
    
    it "should redirect for non-team or account admin" do
      put :remove_all, :id => @team
      response.should redirect_to(@signed_in_user)
    end
    
    describe "for admin" do
      
      before(:each) do
        @accountship = @signed_in_user.accountships.where(:account_id => @account.id).first
        @accountship.admin = true
        @accountship.save
      end
      
      it "should allow account admin" do
        put :remove_all, :id => @team
        response.should redirect_to(assign_team_url(@team))
      end
      
      it "should allow team admin" do
        @accountship.admin = false
        @accountship.save
        membership = @team.memberships.create(:user_id => @signed_in_user.id, :admin => true)
        
        put :remove_all, :id => @team
        response.should redirect_to(assign_team_url(@team))
      end
      
      it "should remove all team members" do
        member_one = Factory(:user, :email => Factory.next(:email))
        member_two = Factory(:user, :email => Factory.next(:email))
        @account.users << member_one
        @account.users << member_two
        @team.users << member_one
        @team.users << member_two
        
        put :remove_all, :id => @team
        
        Membership.where('memberships.team_id = ? AND memberships.active = ?', @team.id, true).count.should eq(0)
      end
    end
  end
  
  describe "PUT 'assign_all'" do
    
    before(:each) do
      @team = @account.teams[0]
    end
    
    it "should not allow unauthenticated user" do
      controller.sign_out
      put :assign_all, :id => @team
      response.should redirect_to(signin_path)
    end
    
    it "should redirect for non-team or account admin" do
      put :assign_all, :id => @team
      response.should redirect_to(@signed_in_user)
    end
    
    describe "for admin" do
      
      before(:each) do
        @accountship = @signed_in_user.accountships.where(:account_id => @account.id).first
        @accountship.admin = true
        @accountship.save
      end
      
      it "should allow account admin" do
        put :assign_all, :id => @team
        response.should redirect_to(assign_team_url(@team))
      end
      
      it "should allow team admin" do
        @accountship.admin = false
        @accountship.save
        membership = @team.memberships.create(:user_id => @signed_in_user.id, :admin => true)
        
        put :assign_all, :id => @team
        response.should redirect_to(assign_team_url(@team))
      end
      
      it "should add all account members to the team" do
        member_one = Factory(:user, :email => Factory.next(:email))
        member_two = Factory(:user, :email => Factory.next(:email))
        @account.users << member_one
        @account.users << member_two
        @team.users << member_one
        @team.users << member_two
        
        put :assign_all, :id => @team
        team = Team.find(@team.id)
        team.users.exists?(member_one).should be_true
        team.users.exists?(member_two).should be_true
        team.users.exists?(@signed_in_user).should be_true
      end
      
      it "should not add non-account members to the team" do
        orphan = Factory(:user, :email => Factory.next(:email))
        put :assign_all, :id => @team
        Team.find(@team.id).users.exists?(orphan).should_not be_true
      end
    end
  end
  
  describe "GET 'assign'" do
    
    before(:each) do
      @team = @account.teams[0]
    end
    
    it "should redirect for non-authenticated users" do
      controller.sign_out
      get :assign, :id => @team
      response.should redirect_to(signin_path)
    end
    
    it "should redirect for non-account or non team admin users" do
      get :assign, :id => @team
      response.should redirect_to(@signed_in_user)
    end
    
    describe "for admin" do
      
      before(:each) do
        @accountship = @signed_in_user.accountships.where('account_id = ?', @account.id).first
        @accountship.admin = true
        @accountship.save
        
        @user_1 = Factory(:user, :last_name => 'user_1', :email => Factory.next(:email))
        @user_2 = Factory(:user, :last_name => 'user_2', :email => Factory.next(:email))
        @user_3 = Factory(:user, :last_name => 'user_3', :email => Factory.next(:email))
        @user_4 = Factory(:user, :last_name => 'user_4', :email => Factory.next(:email))
        @user_1.accounts << @account
        @user_2.accounts << @account
        @user_3.accounts << @account
        @user_4.accounts << @account
        
        @membership_1 = @team.memberships.create(:user_id => @user_1.id)
        @membership_2 = @team.memberships.create(:user_id => @user_2.id)
      end
      
      it "should allow team admin who isn't account admin" do
        @accountship.admin = false
        @accountship.save
        membership = @team.memberships.create(:user_id => @signed_in_user.id, :admin => true)
        get :assign, :id => @team
        
        response.should render_template('assign')
      end
      
      it "should display all the users from account" do
        get :assign, :id => @team
        
        response.should have_selector("label", :content => @user_1.first_name + ' ' + @user_1.last_name)
        response.should have_selector("label", :content => @user_2.first_name + ' ' + @user_2.last_name)
        response.should have_selector("label", :content => @user_3.first_name + ' ' + @user_3.last_name)
        response.should have_selector("label", :content => @user_4.first_name + ' ' + @user_4.last_name)
      end
      
      it "should show users on the team checked" do
        get :assign, :id => @team
        
        response.should have_selector("input[type=checkbox][checked=checked]", :value => @user_1.id.to_s)
        response.should have_selector("input[type=checkbox][checked=checked]", :value => @user_2.id.to_s)
        response.should_not have_selector("input[type=checkbox][checked=checked]", :value => @user_3.id.to_s)
        response.should_not have_selector("input[type=checkbox][checked=checked]", :value => @user_4.id.to_s)
      end
      
      it "should have a back link" do
        get :assign, :id => @team
        response.should have_selector("a", :href => team_memberships_path(@team))
      end
    end
  end
  
  describe "DELETE 'destroy;" do
    
    before(:each) do
      @team = @account.teams[0]
    end
    
    it "should redirect for non-admin users" do
      delete :destroy, :id => @team
      response.should redirect_to(@signed_in_user)
    end
    
    describe "for admin user" do
      
      before(:each) do
        accountship = @signed_in_user.accountships.where('account_id = ?', @account.id).first
        accountship.admin = true
        accountship.save
      end
      
      it "should remove the team" do
        lambda do
          delete :destroy, :id => @team
        end.should change(Team, :count).by(-1)
      end
      
      it "should redirect to users#show with flash message" do
        delete :destroy, :id => @team
        
        response.should redirect_to(@signed_in_user)
        flash[:success] =~ /removed/i
      end
    end
  end
  
  describe "POST 'create'" do
    
    before(:each) do
      @attr = {
        :name => 'New name',
        :banner_text => 'banner text',
        :display_banner => false
      }
    end
    
    it "should redirect non-admin users" do
      post :create, :team => @attr
      response.should redirect_to(@signed_in_user)
    end
    
    describe "for admin" do
      
      before(:each) do
        accountship = @signed_in_user.accountships.where('account_id = ?', @account.id).first
        accountship.admin = true
        accountship.save
      end
      
      it "should create a team given valid attributes" do
        lambda do
          post :create, :team => @attr
        end.should change(Team, :count).by(1)
      end
      
      it "should not create team given invalid attributes" do
        lambda do
          post :create, :team => @attr.merge(:name => '')
        end.should change(Team, :count).by(0)
      end
      
      it "should redirect to teams#show with flash for the new team" do
        post :create, :team => @attr
        response.should redirect_to(team_path(assigns(:team)))
        flash[:success] =~ /successfully saved/i
      end
    end
  end
  
  describe "GET 'new'" do

    it "should redirect non-admin users" do
      get :new
      response.should redirect_to(@signed_in_user)
    end
    
    it "should allow admin users" do
      accountship = @signed_in_user.accountships.where('account_id = ?', @account.id).first
      accountship.admin = true
      accountship.save
      
      get :new
      response.should render_template('new')
    end
  end
  
  describe "PUT 'update'" do
    
    before(:each) do
      @team = @account.teams[0]
      @attr = {
        :name => 'New name',
        :banner_text => 'banner text',
        :display_banner => false
      }
    end
    
    it "should only allow authenticated access" do
      controller.sign_out
      put :update, :id => @team, :team => @attr
      response.should redirect_to(signin_path)
    end
    
    it "should only allow admin access" do
      put :update, :id => @team, :team => @attr
      response.should redirect_to(user_path(@signed_in_user))
    end
    
    describe "for admin users" do
      
      before(:each) do
        accountship = @signed_in_user.accountships.where('account_id = ?', @account.id).first
        accountship.admin = true
        accountship.save
      end
      
      it "should allow access" do
        put :update, :id => @team, :team => @attr
        response.should be_success
      end
      
      it "should require a name" do
        put :update, :id => @team, :team => @attr.merge(:name => '')
        response.should render_template('edit')
        response.should have_selector("div#error_explanation")
      end
      
      it "should update the team given valid attributes" do
        put :update, :id => @team, :team => @attr
        @attr[:name].should eq(Team.find(@team.id).name)
        @attr[:banner_text].should eq(Team.find(@team.id).banner_text)
        @attr[:display_banner].should eq(Team.find(@team.id).display_banner)
      end
      
      it "should not update the team given invalid attributes" do
        put :update, :id => @team, :team => @attr.merge(:name => '', :banner_text => 'different banner text')
        @team.name.should eq(Team.find(@team.id).name)
        @team.banner_text.should eq(Team.find(@team.id).banner_text)
      end
      
      it "should render edit with flash message on success" do
        put :update, :id => @team, :team => @attr
        response.should render_template('edit')
        flash[:success].should =~ /settings have been updated/i
      end
    end
  end
  
  describe "GET 'edit'" do
    
    before(:each) do
      @team = @account.teams[0]
    end
    
    it "should only allow authenticated access" do
      controller.sign_out
      get :edit, :id => @team
      response.should redirect_to(signin_path)
    end
        
    describe "for admin users" do
      
      before(:each) do
        accountship = @signed_in_user.accountships.where('account_id = ?', @account.id).first
        accountship.admin = true
        accountship.save
      end
      
      it "should allow access" do
        get :edit, :id => @team
        response.should render_template('edit')
      end
      
      it "should have the team name and account name in the header" do
        get :edit, :id => @team
        response.should have_selector('h1', :content => @account.teams[0].name)
        response.should have_selector('span', :content => @account.name)
      end
      
      it "should show a delete link in the sidebar" do
        get :edit, :id => @team
        response.should have_selector('a', :href => team_path(@team))
        response.should have_selector('a', :content => "Yes, I understand - delete this team")
      end
    end
    
    describe "for non-admin users" do
      
      it "should deny access" do
        get :edit, :id => @account.teams[0]
        response.should redirect_to(@signed_in_user)
      end
    end
    
  end
    
  describe "GET 'show'" do
    
    it "should be successful" do
      get :show, :id => @account.teams[0]
      response.should be_success
    end
    
    it "should only allow authenticated access" do
      controller.sign_out
      get :show, :id => @account.teams[0]
      response.should redirect_to(signin_path)
    end
    
    it "should have a back to dashboard link" do
      get :show, :id => @account.teams[0]
      response.should have_selector("a", :href => user_path(@signed_in_user.id))
    end
    
    it "should have the team name and account name in the header" do
      get :show, :id => @account.teams[0]
      response.should have_selector('h1', :content => @account.teams[0].name)
      response.should have_selector('span', :content => @account.name)
    end
    
    it "should show a listing of team members in the sidebar"

    describe "for admin users" do
      
      before(:each) do
        accountship = @signed_in_user.accountships.where('account_id = ?', @account.id).first
        accountship.admin = true
        accountship.save
      end
      
      it "should show the correct tabs" do
        get :show, :id => @account.teams[0]
        response.should have_selector('ul.tabs li a', :content => 'Overview')
        response.should have_selector('ul.tabs li a', :content => 'Skills')
        response.should have_selector('ul.tabs li a', :content => 'Events')
        response.should have_selector('ul.tabs li a', :content => 'Files')
        response.should have_selector('ul.tabs li a', :content => 'People and permissions')
        response.should have_selector('ul.tabs li a', :content => 'Email')
      end
      
      it "should show a link to team settings" do
        get :show, :id => @account.teams[0]
        response.should have_selector('a', :content => 'Team settings')
      end
      
      it "should show the new skill link" do
        get :show, :id => @account.teams[0]
        response.should have_selector('div.link_bar a', :content => 'New skill')
      end
      
      it "should show new event link"
      it "should show new file link"
    end
    
    describe "for non-admin users" do
      
      it "should not display the team settings link" do
        get :show, :id => @account.teams[0]
        response.should_not have_selector('a', :content => 'Team settings')
      end
      
      it "should show the correct tabs" do
        get :show, :id => @account.teams[0]

        response.should have_selector('ul.tabs li a', :content => 'Overview')
        response.should_not have_selector('ul.tabs li a', :content => 'Skills')
        response.should have_selector('ul.tabs li a', :content => 'Events')
        response.should have_selector('ul.tabs li a', :content => 'Files')
        response.should_not have_selector('ul.tabs li a', :content => 'People and permissions')
        response.should_not have_selector('ul.tabs li a', :content => 'Email')
      end
    end
    
  end

end
