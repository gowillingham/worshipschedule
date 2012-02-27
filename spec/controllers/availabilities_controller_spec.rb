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
    @membership = @team.memberships.create!(:user_id => @signed_in_user)
    
    @attr = {
      :membership_id => @membership.id.to_s,
      :event_id => @event.id.to_s,
      :approved => true,
      :free => false
    }
  end
  
  describe 'PUT update' do
    
    before(:each) do 
      @availability = Availability.create!(@attr)
      @new_attrib = {
        :membership_id => @availability.membership_id.to_s,
        :event_id => @availability.event_id.to_s,
        :approved => true,
        :free => true
      }
    end
    
    it "should not allow an availability from another team"
    it "should update the availability given valid attributes"
    
    # it "should not allow an availability from another team" do
    # 
    #   put :update, :team_id => @team, :id => availability, :availability => @new_attrib
    #   response.should redirect_to(@signed_in_user)
    #   
    #   xhr :put, :update, :team_id => @team, :id => availability, :availability => @new_attrib.merge(:free => false)
    #   response.response_code.should eq(403) # => forbidden
    # end
    
    # it "should update the availability given valid attributes" do
    #   put :update, :team_id => @team, :id => @availability, :availability => @new_attrib
    #   response.should redirect_to(team_events_path(@team))
    #   Availability.find(@availability.id).free.should be_true
    #   
    #   xhr :put, :update, :team_id => @team, :id => @availability, :availability => @new_attrib.merge(:free => false)
    #   Availability.find(@availability.id).free.should_not be_true      
    # end
  end
  
  describe 'POST create' do

    it "should return error for a membership from another team" do
      team = @account.teams.create(:name => 'orphan team')
      membership = team.memberships.create(:user_id => @signed_in_user.id)
      
      post :create, :team_id => @team, :availability => @attr.merge(:membership_id => membership.id)
      response.should redirect_to(@signed_in_user)
      
      xhr :post, :create, :team_id => @team, :availability => @attr.merge(:membership_id => membership.id)
      response.response_code.should eq(403) # => forbidden      
    end
    
    it "should return error for an event from another team" do
      team = @account.teams.create(:name => 'orphan team')
      event = team.events.create!(:start_at_date => '02-02-2012')
      
      post :create, :team_id => @team, :availability => @attr.merge(:event_id => event.id)
      response.should redirect_to(@signed_in_user)
      
      xhr :post, :create, :team_id => @team, :availability => @attr.merge(:event_id => event.id)
      response.response_code.should eq(403) # => forbidden
    end
    
    it "should add an availability for valid attributes" do
      lambda do
        post :create, :team_id => @team, :availability => @attr
      end.should change(Availability, :count).by(1)
    end
    
    it "should not add an availability for invalid attributes" do
      team = @account.teams.create(:name => 'orphan team')
      event = team.events.create!(:start_at_date => '02-02-2012')

      lambda do
        post :create, :team_id => @team, :availability => @attr.merge(:event_id => event.id)
      end.should change(Availability, :count).by(0)      
    end
  end
end