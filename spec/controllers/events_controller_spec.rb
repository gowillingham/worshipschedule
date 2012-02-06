require 'spec_helper'

describe EventsController do
  render_views

  before(:each) do
    @signed_in_user = Factory(:user)
    @account = Factory(:account)
    @accountship = @account.accountships.create(:user_id =>@signed_in_user, :admin => true)

    signin_user @signed_in_user
    controller.set_session_account(@account)
    
    @team = Factory(:team, :account_id => @account.id)

    @attr = {
      :team_id => @team.id,
      :name => 'New event',
      :description => 'the description',
      :start_at_date => '2012-02-01',
      :start_at_time => '7:30 pm',
      :end_at_date => '',
      :end_at_time => ''
      }
  end
  
  describe "PUT 'slots'" do
    
    before(:each) do
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
      
      @slot11 = @event_1.slots.create(:skillship_id => @skillship1.id)
      @slot12 = @event_1.slots.create(:skillship_id => @skillship2.id)
      @slot21 = @event_2.slots.create(:skillship_id => @skillship1.id)
      @slot22 = @event_2.slots.create(:skillship_id => @skillship2.id)
    end 
    
    it "should allow an account admin" do
      put :slots, :team_id => @team, :id => @event_1, :skill_id => @skill1, :skillship_id_list => []
      
      response.should redirect_to(slots_team_path(@team))
    end
    
    it "should allow a team admin who is not account admin" do
      @team.memberships.create(:user_id => @signed_in_user, :admin => true)
      @accountship.update_attribute(:admin, false)
      put :slots, :team_id => @team, :id => @event_1, :skill_id => @skill1, :skillship_id_list => []

      response.should redirect_to(slots_team_path(@team))
    end
    
    it "should redirect for a regular user" do
      @accountship.update_attribute(:admin, false)
      membership = @team.memberships.create(:user_id => @signed_in_user)
      put :slots, :team_id => @team, :id => @event_1, :skill_id => @skill1, :skillship_id_list => []

      response.should redirect_to(@signed_in_user)
    end
    
    it "should redirect for a team that is not from the current_account" do
      account = Factory(:account)
      team = Factory(:team, :account_id => account.id)
      put :slots, :team_id => team, :id => @event_1, :skill_id => @skill1, :skillship_id_list => []

      response.should redirect_to(@signed_in_user)
      flash[:error].should =~ /don't have permission/i
    end
    
    it "should redirect for an event that does not belong to the current team" do
      team = @account.teams.create(:name => 'Name')
      event = Event.create(@attr.merge(:team_id => team.id))
      put :slots, :team_id => @team, :id => event, :skill_id => @skill1, :skillship_id_list => []

      response.should redirect_to(@signed_in_user)
      flash[:error].should =~ /don't have permission/i
    end
    
    it "should redirect for a skillship from another team" do
      user = Factory(:user, :email => Factory.next(:email))
      @account.users << user
      team = @account.teams.create(:name => 'team')
      skill = team.skills.create(:name => 'skill')
      membership = team.memberships.create(:user_id => user.id)
      skillship = Skillship.create(:skill_id => skill.id, :membership_id => membership.id)
      
      put :slots, :team_id => @team, :id => @event_1, :skill_id => @skill1, :add => [skillship.id.to_s]
      response.should redirect_to(slots_team_path(@team))
      flash[:error].should =~ /do not have permission/i     
      
      put :slots, :team_id => @team, :id => @event_1, :skill_id => @skill1, :remove => [skillship.id.to_s]
      response.should redirect_to(slots_team_path(@team)) 
      flash[:error].should =~ /do not have permission/i     
    end
  
    it "should add slots" do
      @event_1.slots.clear
      lambda do
        put :slots, :team_id => @team, :id => @event_1, :skill_id => @skill1, :add_slots => '<<', :add => [@skillship1.id.to_s]
      end.should change(Slot, :count).by(1)      
    end 
    
    it "should remove slots" do
      lambda do
        put :slots, :team_id => @team, :id => @event_1, :skill_id => @skill2, :remove_slots => '>>', :remove => [@skillship2.id.to_s]
      end.should change(Slot, :count).by(-1)      
    end
  end
  
  describe "GET 'show'" do
    
    before(:each) do
      @event = Event.create(@attr)
      @skill = @team.skills.create(:name => 'skill name')
      
      @user1 = Factory(:user, :last_name => 'User1', :email => Factory.next(:email))
      @user2 = Factory(:user, :last_name => 'User2', :email => Factory.next(:email))
      @user3 = Factory(:user, :last_name => 'User3', :email => Factory.next(:email))
      @account.users << @user1 << @user2 << @user3
      
      @membership1 = @team.memberships.create(:user_id => @user1.id)
      @membership2 = @team.memberships.create(:user_id => @user2.id)
      @membership3 = @team.memberships.create(:user_id => @user3.id)
      
      @skillship1 = @skill.skillships.create(:membership_id => @membership1.id)
      @skillship2 = @skill.skillships.create(:membership_id => @membership2.id)
      @skillship3 = @skill.skillships.create(:membership_id => @membership3.id)
      
      @event.slots.create(:skillship_id => @skillship1.id)
      @event.slots.create(:skillship_id => @skillship2.id)
      @event.slots.create(:skillship_id => @skillship3.id)
    end
    
    it "should allow an account admin" do
      get :show, :team_id => @team, :id => @event
      
      response.should render_template('show')
    end
    
    it "should allow a team admin who is not account admin" do
      @team.memberships.create(:user_id => @signed_in_user, :admin => true)
      @accountship.update_attribute(:admin, false)
      get :show, :team_id => @team, :id => @event

      response.should render_template('show')
    end
    
    it "should allow a regular user" do
      @accountship.update_attribute(:admin, false)
      membership = @team.memberships.create(:user_id => @signed_in_user)
      get :show, :team_id => @team, :id => @event

      response.should render_template('show')
    end
    
    it "should redirect for a team that is not from the current_account" do
      account = Factory(:account)
      team = Factory(:team, :account_id => account.id)
      get :show, :team_id => team, :id => @event

      response.should redirect_to(@signed_in_user)
      flash[:error].should =~ /don't have permission/i
    end
    
    it "should redirect for an event that does not belong to the current team" do
      team = @account.teams.create(:name => 'Name')
      event = Event.create(@attr.merge(:team_id => team.id))
      get :show, :team_id => @team, :id => event

      response.should redirect_to(@signed_in_user)
      flash[:error].should =~ /don't have permission/i
    end
    
    it "should not show admin features to regular user" do
      @accountship.update_attribute(:admin, false)
      get :show, :team_id => @team, :id => @event

      response.should_not have_selector('a', :content => 'remove')
      response.should_not have_selector('a', :content => 'Change')
      response.should_not have_selector('a', :content => 'Edit')
    end
    
    it "should show listing of active members scheduled for this event in sidebar" do
      get :show, :team_id => @team, :id => @event

      assert_select "#sidebar ul" do |elements|
        elements.each do |element|
          assert_select element, 'li', 3
          assert_select element, 'li', :text => /#{@user1.name_or_email}/
          assert_select element, 'li', :text => /#{@user2.name_or_email}/
          assert_select element, 'li', :text => /#{@user3.name_or_email}/
        end
      end
    end
    
    it "should list a member only one time if they are slotted for multiple skills" do
      skill2 = @team.skills.create(:name => 'Skill 2')
      skillship12 = skill2.skillships.create(:membership_id => @membership1.id)
      @event.slots.create(:skillship_id => skillship12.id)
      get :show, :team_id => @team, :id => @event
      
      assert_select "#sidebar ul" do |elements|
        elements.each do |element|
          assert_select element, 'li', 3
          assert_select element, 'li', { :count => 1, :text => /#{@user1.name_or_email}/ }
        end
      end 
    end
    
    it "should show blank slate if no members are scheduled" do
      @event.slots.clear
      get :show, :team_id => @team, :id => @event
      
      response.should have_selector('li', :class => 'blank_slate', :content => 'No one has been scheduled')
    end
  end
  
  describe "DELETE 'destroy'" do
    
    before(:each) do
      @event = Event.create(@attr)
    end
    
    it "should allow an account admin" do
      delete :destroy, :team_id => @team, :id => @event
      
      response.should redirect_to(team_events_path(@team))
    end
    
    it "should allow a team admin who is not account admin" do
      @team.memberships.create(:user_id => @signed_in_user, :admin => true)
      @accountship.update_attribute(:admin, false)
      delete :destroy, :team_id => @team, :id => @event
      
      response.should redirect_to(team_events_path(@team))
    end
    
    it "should redirect a regular user" do
      @accountship.update_attribute(:admin, false)
      delete :destroy, :team_id => @team, :id => @event
      
      response.should redirect_to(@signed_in_user)
      flash[:error].should =~ /don't have permission/i
    end
    
    it "should redirect for a team that is not from the current_account" do
      account = Factory(:account)
      team = Factory(:team, :account_id => account.id)
      delete :destroy, :team_id => team, :id => @event
      
      response.should redirect_to(@signed_in_user)
      flash[:error].should =~ /don't have permission/i
    end
    
    it "should redirect for an event that does not belong to the current team" do
      team = @account.teams.create(:name => 'Name')
      event = Event.create(@attr.merge(:team_id => team.id))
      delete :destroy, :team_id => @team, :id => event

      response.should redirect_to(@signed_in_user)
      flash[:error].should =~ /don't have permission/i
    end
    
    it "should redirect to events#index with message on success" do
      delete :destroy, :team_id => @team, :id => @event
      
      response.should redirect_to team_events_path(@team)
      flash[:success].should =~ /event was removed/i
    end 
    
    it "should remove the event" do
      lambda do
        delete :destroy, :team_id => @team, :id => @event
      end.should change(Event, :count).by(-1)
    end    
  end
  
  describe "PUT 'update'" do
    
    before(:each) do
      @event = Event.create(@attr)
      @new_attr = {:name => 'New name', :description => 'Some new stuff', :start_at_time => '11:30 pm'}
    end
    
    it "should allow an account admin" do
      put :update, :team_id => @team, :id => @event, :event => @new_attr
      
      response.should redirect_to(team_events_path(@team))
    end
    
    it "should allow a team admin who is not account admin" do
      @team.memberships.create(:user_id => @signed_in_user, :admin => true)
      @accountship.update_attribute(:admin, false)
      put :update, :team_id => @team, :id => @event, :event => @new_attr
      
      response.should redirect_to(team_events_path(@team))
    end
    
    it "should redirect a regular user" do
      @accountship.update_attribute(:admin, false)
      put :update, :team_id => @team, :id => @event, :event => @new_attr
      
      response.should redirect_to(@signed_in_user)
      flash[:error].should =~ /don't have permission/i
    end
    
    it "should redirect for a team that is not from the current_account" do
      account = Factory(:account)
      team = Factory(:team, :account_id => account.id)
      put :update, :team_id => team, :id => @event, :event => @new_attr
      
      response.should redirect_to(@signed_in_user)
      flash[:error].should =~ /don't have permission/i
    end
    
    it "should redirect for an event that does not belong to the current team" do
      team = @account.teams.create(:name => 'Name')
      event = Event.create(@attr.merge(:team_id => team.id))
      put :update, :team_id => @team, :id => event, :event => @new_attr

      response.should redirect_to(@signed_in_user)
      flash[:error].should =~ /don't have permission/i
    end
    
    it "should update given valid attributes" do
      attrib = { 
        :name => 'New name for this event', 
        :description => 'yes there is one',
        :start_at_date => '2001-01-01',
        :start_at_time => '5:01 pm',
        :end_at_date => '2012-06-01'
      }
      put :update, :team_id => @team, :id => @event, :event => attrib
      
      Event.find(@event.id).name.should eq(attrib[:name])
      Event.find(@event.id).description.should eq(attrib[:description])
      Event.find(@event.id).start_at_date.should eq(attrib[:start_at_date])
      Event.find(@event.id).start_at_time.should eq(attrib[:start_at_time])
      Event.find(@event.id).end_at_date.should be_nil
      Event.find(@event.id).end_at_time.should be_nil
      
      response.should redirect_to(team_events_path(@team))
      flash[:success].should =~ /event were saved/i
    end
    
    it "should not update given invalid date" do
      put :update, :team_id => @team, :id => @event, :event => { :start_at_date => '2012-02-31' }
      
      @event.reload.start_at_date.should eq(@attr[:start_at_date])
    end
    
    it "should not update given invalid attributes" do
      put :update, :team_id => @team, :id => @event, :event => @new_attr.merge(:start_at_date => '')
      
      @event.reload.start_at_date.should eq(@attr[:start_at_date])
    end
  end
  
  describe "GET 'edit'" do
    
    before(:each) do
      @event = Event.create(@attr)
      @skill = @team.skills.create(:name => 'skill name')
      
      @user1 = Factory(:user, :last_name => 'User1', :email => Factory.next(:email))
      @user2 = Factory(:user, :last_name => 'User2', :email => Factory.next(:email))
      @user3 = Factory(:user, :last_name => 'User3', :email => Factory.next(:email))
      @account.users << @user1 << @user2 << @user3
      
      @membership1 = @team.memberships.create(:user_id => @user1.id)
      @membership2 = @team.memberships.create(:user_id => @user2.id)
      @membership3 = @team.memberships.create(:user_id => @user3.id)
      
      @skillship1 = @skill.skillships.create(:membership_id => @membership1.id)
      @skillship2 = @skill.skillships.create(:membership_id => @membership2.id)
      @skillship3 = @skill.skillships.create(:membership_id => @membership3.id)
      
      @event.slots.create(:skillship_id => @skillship1.id)
      @event.slots.create(:skillship_id => @skillship2.id)
      @event.slots.create(:skillship_id => @skillship3.id)
    end
    
    it "should allow an account admin" do
      get :edit, :team_id => @team, :id => @event
      
      response.should render_template('edit')
    end
    
    it "should allow a team admin who is not account admin" do
      @team.memberships.create(:user_id => @signed_in_user, :admin => true)
      @accountship.update_attribute(:admin, false)
      get :edit, :team_id => @team, :id => @event
      
      response.should render_template('edit')
    end
    
    it "should redirect a regular user" do
      @accountship.update_attribute(:admin, false)
      get :edit, :team_id => @team, :id => @event
      
      response.should redirect_to(@signed_in_user)
      flash[:error].should =~ /don't have permission/i
    end
    
    it "should redirect for a team that is not from the current_account" do
      account = Factory(:account)
      team = Factory(:team, :account_id => account.id)
      get :edit, :team_id => team, :id => @event
      
      response.should redirect_to(@signed_in_user)
      flash[:error].should =~ /don't have permission/i
    end
    
    it "should redirect for an event that does not belong to the current team" do
      team = @account.teams.create(:name => 'Name')
      event = Event.create(@attr.merge(:team_id => team.id))
      get :edit, :team_id => @team, :id => event

      response.should redirect_to(@signed_in_user)
      flash[:error].should =~ /don't have permission/i
    end

    it "should show listing of active members scheduled for this event in sidebar" do
      get :edit, :team_id => @team, :id => @event
    
      assert_select "#sidebar ul" do |elements|
        elements.each do |element|
          assert_select element, 'li', 3
          assert_select element, 'li', :text => /#{@user1.name_or_email}/
          assert_select element, 'li', :text => /#{@user2.name_or_email}/
          assert_select element, 'li', :text => /#{@user3.name_or_email}/
        end
      end
    end
    
    it "should list a member only one time if they are slotted for multiple skills" do
      skill2 = @team.skills.create(:name => 'Skill 2')
      skillship12 = skill2.skillships.create(:membership_id => @membership1.id)
      @event.slots.create(:skillship_id => skillship12.id)
      get :edit, :team_id => @team, :id => @event
      
      assert_select "#sidebar ul" do |elements|
        elements.each do |element|
          assert_select element, 'li', 3
          assert_select element, 'li', { :count => 1, :text => /#{@user1.name_or_email}/ }
        end
      end 
    end
    
    it "should show blank slate if no members are scheduled" do
      @event.slots.clear
      get :edit, :team_id => @team, :id => @event
       
      response.should have_selector('li', :class => 'blank_slate', :content => 'No one has been scheduled')
    end
  end

  describe "GET 'index'" do
    
    before(:each) do
      @event_1 = @team.events.create(@attr)
      @event_2 = @team.events.create(@attr.merge(:name => 'event 2', :start_at_date => '2012-02-15', :start_at_time => '12:00 pm', :end_at_date => nil, :end_at_time => nil))
      @event_3 = @team.events.create(@attr.merge(:name => 'event 3', :start_at_date => '2012-02-15', :start_at_time => '5:00 pm', :end_at_date => nil, :end_at_time => nil))
    end 
    
    it "should allow an account admin" do
      get :index, :team_id => @team

      response.should render_template('index')
    end
    
    it "should allow a team admin who is not account admin" do
      @team.memberships.create(:user_id => @signed_in_user, :admin => true)
      @accountship.update_attribute(:admin, false)
      get :index, :team_id => @team
      
      response.should render_template('index')
    end
    
    it "should allow a regular team member" do
      @accountship.update_attribute(:admin, false)
      @team.memberships.create(:user_id => @signed_in_user, :admin => false)
      get :index, :team_id => @team
      
      response.should render_template('index')
    end
    
    it "should redirect for a user who is not a team member" do
      @accountship.update_attribute(:admin, false)
      get :index, :team_id => @team
      
      response.should redirect_to(@signed_in_user)
    end
    
    it "should redirect for a team that is not from the current_account" do
      account = Factory(:account)
      team = Factory(:team, :account_id => account.id)
      get :index, :team_id => team
      
      response.should redirect_to(@signed_in_user)
      flash[:error].should =~ /don't have permission/i
    end 
    
    it "should display a listing of events for the team with event name as link to event#show" do
      get :index, :team_id => @team
      
      response.should have_selector('a', :content => @event_1.name, :href => team_event_path(@team, @event_1))
      response.should have_selector('a', :content => @event_2.name, :href => team_event_path(@team, @event_2))
      response.should have_selector('a', :content => @event_3.name, :href => team_event_path(@team, @event_3))
    end
    
    it "should display a rollover link to event#edit" do
      get :index, :team_id => @team
      
      response.should have_selector('a', :content => 'Edit', :href => edit_team_event_path(@team, @event_1))
      response.should have_selector('a', :content => 'Edit', :href => edit_team_event_path(@team, @event_2))
      response.should have_selector('a', :content => 'Edit', :href => edit_team_event_path(@team, @event_3))      
    end
    
    it "should not display admin features to a regular user" do
      @accountship.update_attribute(:admin, false)
      membership = @team.memberships.create(:user_id =>@signed_in_user.id, :admin => false)
      get :index, :team_id => @team

      response.should_not have_selector('a', :content => 'Edit', :href => edit_team_event_path(@team, @event_1))
      response.should_not have_selector('a', :content => 'Edit', :href => edit_team_event_path(@team, @event_2))
      response.should_not have_selector('a', :content => 'Edit', :href => edit_team_event_path(@team, @event_3)) 
      response.should_not have_selector('a', :content => 'New event', :href => new_team_event_path(@team))     
    end

    it "should display a blank slate to an admin if there are no events for the team" do
      @team.events.clear
      get :index, :team_id => @team 
      
      response.should have_selector('div.blank_slate', :content => "Let's add the first event")
    end
    
    it "should display a blank slate to a regular user if there are no events for the team" do
      @accountship.update_attribute(:admin, false)
      membership = @team.memberships.create(:user_id =>@signed_in_user.id, :admin => false)
      @team.events.clear
      get :index, :team_id => @team 
      
      response.should have_selector('div.blank_slate', :content => "A team administrator still needs to create some events")
    end

    it "should display a list of scheduled events for the current_user in the sidebar" 
    it "should display a blank slate message in the sidebar if the current_user is not scheduled for any events"  
  end
  
  describe "POST 'create'" do
    
    it "should allow an account admin" do
      post :create, :team_id => @team, :event => @attr
      
      response.should redirect_to(team_events_path(@team))
    end
    
    it "should allow a team admin who is not account admin" do
      @team.memberships.create(:user_id => @signed_in_user, :admin => true)
      @accountship.update_attribute(:admin, false)
      post :create, :team_id => @team, :event => @attr
      
      response.should redirect_to(team_events_path(@team))
    end
    
    it "should redirect a regular user" do
      @accountship.update_attribute(:admin, false)
      post :create, :team_id => @team, :event => @attr
      
      response.should redirect_to(@signed_in_user)
      flash[:error].should =~ /don't have permission/i
    end
    
    it "should redirect for a team that is not from the current_account" do
      account = Factory(:account)
      team = Factory(:team, :account_id => account.id)
      post :create, :team_id => team, :event => @attr
      
      response.should redirect_to(@signed_in_user)
      flash[:error].should =~ /don't have permission/i
    end
    
    it "should add the event given valid attributes" do
      lambda do
        post :create, :team_id => @team, :event => @attr
      end.should change(Event, :count).by(1)
    end
    
    it "should not add the event given invalid attributes" do
      lambda do
        post :create, :team_id => @team, :event => @attr.merge(:end_at_date => '2011-02-01')
      end.should change(Event, :count).by(0)
    end
    
    it "should redirect to #teams#events#index on success" do
      post :create, :team_id => @team, :event => @attr
      
      response.should redirect_to(team_events_path(@team))
      flash[:success].should =~ /successfully saved/i
    end
  end
  
  describe "GET 'new'" do

    it "should allow an account admin" do
      get :new, :team_id => @team
      
      response.should render_template('new')
    end
    
    it "should allow a team admin who is not account admin" do
      @team.memberships.create(:user_id => @signed_in_user, :admin => true)
      @accountship.update_attribute(:admin, false)
      get :new, :team_id => @team
      
      response.should render_template('new')
    end
    
    it "should redirect a regular user" do
      @accountship.update_attribute(:admin, false)
      get :new, :team_id => @team
      
      response.should redirect_to(@signed_in_user)
      flash[:error].should =~ /don't have permission/i
    end
    
    it "should redirect for a team that is not from the current_account" do
      account = Factory(:account)
      team = Factory(:team, :account_id => account.id)
      get :new, :team_id => team
      
      response.should redirect_to(@signed_in_user)
      flash[:error].should =~ /don't have permission/i
    end
  end
end