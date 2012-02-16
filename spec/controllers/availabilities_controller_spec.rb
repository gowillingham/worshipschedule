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
  
  describe 'PUT update' do
    it "should not allow an availability from another team"
    it "it should update the availability given valid attributes"
  end
  
  describe 'POST create' do

    it "should return error for a membership from another team" do
      post :create, :team_id => @team, :availability => @attr
      response.should redirect_to(@signed_in_user)
      
      xhr :post, :create, :team_id => @team, :availability => @attr
      response.response_code.should eq(403) # => forbidden      
    end
    
    it "should return error for an event from another team" do
      post :create, :team_id => @team, :availability => @attr
      response.should redirect_to(@signed_in_user)
      
      xhr :post, :create, :team_id => @team, :availability => @attr
      response.response_code.should eq(403) # => forbidden
    end
    
    it "should add an availability for valid attributes" do
      lambda do
        post :create, :team_id => @team, :availability => @attr
      end.should change(Availability, :count).by(1)
    end
    
    it "should not add an availability for invalid attributes"
  end
end