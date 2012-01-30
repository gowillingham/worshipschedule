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
    
  describe "GET 'slots'" do
    
    before(:each) do
      @team = @account.teams[0]
      @accountship = @signed_in_user.accountships.where('account_id = ?', @account.id).first
      @accountship.update_attribute(:admin, true)
      
      @skill1 = @team.skills.create(:name => 'skill1')
      @skill2 = @team.skills.create(:name => 'skill2')
      @skill3 = @team.skills.create(:name => 'skill3')
      
      @user_1 = Factory(:user, :last_name => 'user_1', :email => Factory.next(:email))
      @user_2 = Factory(:user, :last_name => 'user_2', :email => Factory.next(:email))
      @account.users << @user_1 << @user_2
      @membership_1 = @team.memberships.create(:user_id => @user_1.id)
      @membership_2 = @team.memberships.create(:user_id => @user_2.id)
      
      @skillship1 = @skill1.skillships.create(:membership_id => @membership_1.id)
      @skillship2 = @skill2.skillships.create(:membership_id => @membership_2.id)
      @skillship31 = @skill3.skillships.create(:membership_id => @membership_1.id)
      @skillship32 = @skill3.skillships.create(:membership_id => @membership_2.id)
    
      @event_1 = @team.events.create(:start_at_date => Time.now.strftime("%Y-%m-%d"), :name => 'Event 1')
      @event_2 = @team.events.create(:start_at_date => 1.day.since(Time.now).strftime("%Y-%m-%d"), :name => 'Event 2')
      @event_3 = @team.events.create(:start_at_date => 2.day.since(Time.now).strftime("%Y-%m-%d"), :name => 'Event 3')
    
      @event_list = [@event_1.id.to_s, @event_2.id.to_s, @event_3.id.to_s]
    end
    
    it "should redirect if not logged in" do
      controller.sign_out
      get :slots, :id => @team, :show_events => nil
      
      response.should redirect_to(signin_path)
    end
    
    it "should allow account admin" do
      get :slots, :id => @team
      
      response.should render_template('slots')
    end
    
    it "should allow team admin" do
      @membership = @team.memberships.create(:user_id => @signed_in_user.id, :admin => true)
      @accountship.update_attribute(:admin, false)
      get :slots, :id => @team
      
      response.should render_template('slots')
    end
    
    it "should allow regular team member" do
      @membership = @team.memberships.create(:user_id => @signed_in_user.id, :admin => false)
      @accountship.update_attribute(:admin, false)
      get :slots, :id => @team
      
      response.should render_template('slots')
    end
    
    it "should redirect for a non-admin, non-team member" do
      @accountship.update_attribute(:admin, false)
      get :slots, :id => @team
      
      response.should redirect_to(@signed_in_user)
    end 
    
    it "should redirect for a team from another account" do
      account = Factory(:account)
      team = account.teams.create(:name => 'name')
      get :slots, :id => team
      
      response.should redirect_to(@signed_in_user)
    end
    
    it "should redirect for an event from another account" do
      account = Factory(:account)
      team = account.teams.create(:name => 'name')
      event = team.events.create(:start_at_date => '2000-01-02', :name => 'orphan event')
      get :slots, :id => @team, :show_events => @event_list << event.id.to_s
      
      response.should redirect_to(@signed_in_user)
    end 
    
    it "should display events posted from form in main content area" do
      get :slots, :id => @team, :show_events => @event_list
      
      response.should have_selector('td', :content => @event_1.name)
      response.should have_selector('td', :content => @event_2.name)
      response.should have_selector('td', :content => @event_3.name)
    end
    
    it "should show a listing of events in the sidebar" do
      get :slots, :id => @team, :show_events => @event_list
      
      response.should have_selector('label', :content => @event_1.name)
      response.should have_selector('label', :content => @event_2.name)
      response.should have_selector('label', :content => @event_3.name)
    end
    
    it "should show posted events as selected in sidebar" do
      get :slots, :id => @team, :show_events => [@event_1.id.to_s, @event_3.id.to_s], :reset_events? => 'on'

      response.should have_selector("input[type=checkbox][checked=checked]", :value => @event_1.id.to_s)
      response.should have_selector("input[type=checkbox]", :value => @event_2.id.to_s)
      response.should_not have_selector("input[type=checkbox][checked=checked]", :value => @event_2.id.to_s)
      response.should have_selector("input[type=checkbox][checked=checked]", :value => @event_3.id.to_s)
    end
    
    it "should show a  blank slate message if no events are selected in the sidebar" do
      get :slots, :id => @team, :show_events => [], :reset_events? => 'on'
      
      response.should have_selector('.blank_slate', :content => "have not selected any events")
    end 
    
    it "should show a blank slate message if the team has no skills" do
      @team.skills.clear
      get :slots, :id => @team, :show_events => [@event_1.id.to_s, @event_3.id.to_s]
      
      response.should have_selector('.blank_slate', :content => 'No skills are set for this team')
    end
    
    it "should show a blank slate message if the team has no events" do
      @team.events.clear
      get :slots, :id => @team, :show_events => []
      
      response.should have_selector('.blank_slate', :content => "You'll use this page to assign your people to events, but you don't have any yet!")
    end

    it "should show a listing of skills in the main display table" do
      get :slots, :id => @team, :show_events => @event_list
      
      response.should have_selector('td.skills', :content => @skill1.name)
      response.should have_selector('td.skills', :content => @skill2.name)
      response.should have_selector('td.skills', :content => @skill3.name)
    end
    
    it "should have a hidden form to update slots for each skill/event" do
      get :slots, :id => @team, :show_events => @event_list
      
      response.should have_selector('form', :action => slots_team_event_path(@team, @event_1))
      response.should have_selector('form', :action => slots_team_event_path(@team, @event_2))
      response.should have_selector('form', :action => slots_team_event_path(@team, @event_3))
    end
    
    it "should have a hidden dropdown of skillships for each skill/event" do
      get :slots, :id => @team, :show_events => @event_list
      
      response.should have_selector('select option', :content => @user_1.last_name, :value => @skillship1.id.to_s)
      response.should have_selector('select option', :content => @user_2.last_name, :value => @skillship2.id.to_s)
      response.should have_selector('select option', :content => @user_1.last_name, :value => @skillship31.id.to_s)
      response.should have_selector('select option', :content => @user_2.last_name, :value => @skillship32.id.to_s)
    end
    
    it "should show members scheduled in one dropdown and members not scheduled in the other"
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
      
      it "should redirect for a team admin from another team" do
        @accountship.update_attribute(:admin, false)
        @membership.update_attribute(:admin, false)
        team = Factory(:team, :account_id => @account.id)
        membership = team.memberships.create(:user_id => @signed_in_user.id, :admin => true)
        get :admins, :id => @team
        
        response.should redirect_to(@signed_in_user)
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
      
      it "should redirect for a team admin from another team" do
        @accountship.update_attribute(:admin, false)
        @membership.update_attribute(:admin, false)
        team = Factory(:team, :account_id => @account.id)
        membership = team.memberships.create(:user_id => @signed_in_user.id, :admin => true)
        put :update_admins, :id => @team, :membership_id => []
        
        response.should redirect_to(@signed_in_user)
      end
      
      it "should allow account admin" do
        put :update_admins, :id => @team, :membership_id => []
        
        response.should redirect_to edit_team_path(@team)
      end
      
      it "should allow team admin that is not account admin" do
        @accountship.admin = false
        @accountship.save
        @membership.admin = true
        @membership.save

        put :update_admins, :id => @team, :membership_id => [@membership.id.to_s]

        response.should redirect_to edit_team_path(@team)
      end 
      
      it "should update the admin status of a list of team members" do 
        membership_id = [@membership_1.user_id.to_s, @membership_3.user_id.to_s]
        put :update_admins, :id => @team, :membership_id => membership_id
        
        Membership.where(:user_id => @membership_1.user_id, :team_id => @team.id).first.admin.should be_true
        Membership.where(:user_id => @membership_2.user_id, :team_id => @team.id).first.admin.should_not be_true
        Membership.where(:user_id => @membership_3.user_id, :team_id => @team.id).first.admin.should be_true
      end 
      
      it "should not allow user to remove self from admin role" do
        @accountship.admin = false
        @accountship.save
        @membership.admin = true
        @membership.save
        
        put :update_admins, :id => @team, :membership_id => []
        
        flash[:error].should =~ /remove yourself/i
        response.should redirect_to admins_team_path(@team)
      end 
    
      it "should redirect to team settings page teams/id/edit on success" do
        membership_id = [@membership_1.user_id.to_s, @membership_3.user_id.to_s]
        put :update_admins, :id => @team, :membership_id => membership_id
        
        flash[:success].should =~ /changes have been saved/i
        response.should redirect_to edit_team_path(@team)
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
      
      it "should redirect for a team admin from another team" do
        @accountship.update_attribute(:admin, false)
        team = Factory(:team, :account_id => @account.id)
        membership = team.memberships.create(:user_id => @signed_in_user.id, :admin => true)
        put :remove_all, :id => @team
        
        response.should redirect_to(@signed_in_user)
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
      
      it "should redirect for a team admin from another team" do
        @accountship.update_attribute(:admin, false)
        team = Factory(:team, :account_id => @account.id)
        membership = team.memberships.create(:user_id => @signed_in_user.id, :admin => true)
        put :assign_all, :id => @team
        
        response.should redirect_to(@signed_in_user)
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
      
      it "should redirect for a team admin from another team" do
        @accountship.update_attribute(:admin, false)
        team = Factory(:team, :account_id => @account.id)
        membership = team.memberships.create(:user_id => @signed_in_user.id, :admin => true)
        get :assign, :id => @team
        
        response.should redirect_to(@signed_in_user)
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
        flash[:success].should =~ /removed/i
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
      
      it "should redirect to teams#show with for the new team" do
        post :create, :team => @attr
        response.should redirect_to(team_path(assigns(:team)))
        flash[:success].should =~ /successfully saved/i
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
    
    it "should redirect for a regular user" do
      put :update, :id => @team, :team => @attr
      
      response.should redirect_to(user_path(@signed_in_user))
    end
    
    describe "for admin users" do
      
      before(:each) do
        accountship = @signed_in_user.accountships.where('account_id = ?', @account.id).first
        accountship.admin = true
        accountship.save
      end
      
      it "should allow access for account admin" do
        put :update, :id => @team, :team => @attr
        response.should be_success
      end
      
      it "should allow access or team admin" do
        accountship = @signed_in_user.accountships.where('account_id = ?', @account.id).first
        accountship.update_attribute(:admin, false)
        membership = @team.memberships.create(:user_id => @signed_in_user.id, :admin => true)
        put :update, :id => @team, :team => @attr
        
        response.should render_template('edit')
      end
      
      it "should redirect for a team admin from another team" do
        accountship = @signed_in_user.accountships.where('account_id = ?', @account.id).first
        accountship.update_attribute(:admin, false)
        team = Factory(:team, :account_id => @account.id)
        membership = team.memberships.create(:user_id => @signed_in_user.id, :admin => true)
        put :update, :id => @team, :team => @attr
        
        response.should redirect_to(@signed_in_user)
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
        
        @account_owner = Factory(:user, :email => Factory.next(:email))
        @account.users << @account_owner
        @account.owner_id = @account_owner.id
        @account.save
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
      
      it "should show a listing of administrators in the sidebar" do
        team_administrator = Factory(:user, :first_name => 'new_team', :last_name => 'administrator', :email => Factory.next(:email))
        @account.users << team_administrator
        membership = @team.memberships.create(:user_id => team_administrator.id, :admin => true)
        
        get :edit, :id => @team

        response.should have_selector('li', :content => @signed_in_user.name_or_email)
        response.should have_selector('li', :content => @account_owner.name_or_email)
        response.should have_selector('li', :content => team_administrator.name_or_email)
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
    
    before(:each) do
      @membership = @account.teams[0].memberships.create(:user_id => @signed_in_user, :admin => false)
    end
    
    it "should be successful" do
      get :show, :id => @account.teams[0]
      response.should be_success
    end
    
    it "should only allow authenticated access" do
      controller.sign_out
      get :show, :id => @account.teams[0]
      response.should redirect_to(signin_path)
    end
    
    it "should redirect for a member from another team" do
      accountship = @signed_in_user.accountships.where('account_id = ?', @account.id).first
      accountship.update_attribute(:admin, false)
      team = Factory(:team, :account_id => @account.id)
      membership = team.memberships.create(:user_id => @signed_in_user.id, :admin => true)
      @membership.delete
      get :show, :id => @account.teams[0]
      
      response.should redirect_to(@signed_in_user)
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

    it "should show a listing of team members in the sidebar" do
      first = Factory(:user, :email => Factory.next(:email), :first_name => "first", :last_name => "user")
      second = Factory(:user, :email => Factory.next(:email), :first_name => "second", :last_name => "user")
      third = Factory(:user, :email => Factory.next(:email), :first_name => "third", :last_name => "user")
      @account.users << first << second << third
      @account.teams[0].users << first << second << third
      get :show, :id => @account.teams[0]
      
      response.should have_selector('li', :content => first.name_or_email)
      response.should have_selector('li', :content => second.name_or_email)
      response.should have_selector('li', :content => third.name_or_email)
    end
    
    describe "for admin users" do
      
      before(:each) do
        accountship = @signed_in_user.accountships.where('account_id = ?', @account.id).first
        accountship.admin = true
        accountship.save
      end
      
      it "should show a message in the sidebar if there are no team members for the team" do
        @account.teams[0].memberships.clear
        get :show, :id => @account.teams[0]

        response.should have_selector('li.blank_slate', :content => "None of the people")
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
        response.should have_selector('a', :content => 'New skill')
      end
      
      it "should show new event link" do
        get :show, :id => @account.teams[0]
        
        response.should have_selector('a', :content => 'New event', :href => new_team_event_path(@account.teams[0]))
      end
      
      it "should show new file link"
    end
    
    describe "for non-admin users" do
      
      it "should not display the team settings link" do
        get :show, :id => @account.teams[0]
        response.should_not have_selector('a', :content => 'Team settings')
      end
      
      it "should not display the new skill link" do
        get :show, :id => @account.teams[0]
        response.should_not have_selector('div.link_bar a', :content => 'New skill')
      end 
      
      it "should show the correct tabs" do
        get :show, :id => @account.teams[0]

        response.should have_selector('ul.tabs li a', :content => 'Overview')
        response.should have_selector('ul.tabs li a', :content => 'Skills')
        response.should have_selector('ul.tabs li a', :content => 'Events')
        response.should have_selector('ul.tabs li a', :content => 'Files')
        response.should_not have_selector('ul.tabs li a', :content => 'People and permissions')
        response.should_not have_selector('ul.tabs li a', :content => 'Email')
      end
    end    
  end
end
