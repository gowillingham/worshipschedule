require 'spec_helper'

describe AvailabilitiesController do
  render_views

  before(:each) do
    @account = Factory(:account)
    @signed_in_user = Factory(:user, :email => Factory.next(:email))
    @account.users << @signed_in_user
    
    signin_user @signed_in_user
    controller.set_session_account(@account)    
    
    @team = @account.teams.create(:name => 'Team')
    @event = @team.events.create!(:start_at_date => '2012-02-14')
    @membership = @team.memberships.create(:user_id => @signed_in_user)
    
    @attr = {
      :membership_id => @membership.id,
      :event_id => @event.id
    }
  end
  
  describe 'POST create' do
    
    it "should return an error for a non-team member" do
      @signed_in_user.teams.clear
      post :create, :team_id => @team, :availability => @attr
      
      response.should_not be_success
    end
     
    it "should return error for a membership that doesn't belong to current_user" do
      # user = Factory(:user, :email => Factory.next(:email))
      # @account.users << user
      # membership = @team.memberships.create(:user_id => user.id)
      # post :create, :team_id => @team, :availability => @attr.merge(:membership_id => membership.id)
      # 
      # response.should_not be_success
    end
    
    it "should return error for an event that doesn't belong to current_user"
    it "should return error for a membership from another team"
    it "should return error for an event from another team"
    
    it "should add an availability for valid attributes" do
      lambda do
        post :create, :team_id => @team, :availability => @attr
      end.should change(Availability, :count).by(1)
    end
  end
end