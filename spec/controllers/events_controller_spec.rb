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
      :start_at_date => '2012-02-01 19:30',
      :end_at => '2012-02-01 21:30',
      :all_day => false
    }
  end

  describe "GET 'index'" do
    
    before(:each) do
      @event_1 = @team.events.create(@attr)
      @event_2 = @team.events.create(@attr.merge(:name => 'event 2', :start_at => '2012-02-15 12:00', :end_at => nil))
      @event_3 = @team.events.create(@attr.merge(:name => 'event 3', :start_at => '2012-02-15 5:00', :end_at => nil))
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
        post :create, :team_id => @team, :event => @attr.merge(:start_at_date => nil)
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