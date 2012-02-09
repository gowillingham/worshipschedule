require 'spec_helper'

describe Availability do
  
  before(:each) do
    @account = Factory(:account)
    @user = Factory(:user, :email => Factory.next(:email))
    @account.users << @user
    
    @team = @account.teams.create(:name => 'Team')
    @membership = @team.memberships.create(:user_id => @user.id)
    @event = @team.events.create!(:start_at_date => "2012-02-14")

    @availability = Availability.create(:event_id => @event.id, :membership_id => @membership.id)
  end
  
  describe "methods" do
    
    it "should include event" do
      @availability.should respond_to(:event)
    end
    
    it "should include membership" do 
      @availability.should respond_to(:membership)
    end
  end
end
