require 'spec_helper'

describe Team do
  
  before(:each) do
    @account = Factory(:account)
    @team = Factory(:team, :account_id => @account.id)
  end
  
  describe "validations" do
    
    it "should require an account_id" do
      team = Team.new(:name => 'Team')
      team.should_not be_valid
    end 
  end
  
  describe "methods" do
    it "should have a new_availability_for? method" do
      @team.should respond_to(:new_availability_for?)
    end
    
    describe "new_availability_for?" do
      before(:each) do
        @user = Factory(:user)
        @accountship = @account.accountships.create(:user_id => @user.id)
        @membership = Membership.create!(:user_id => @user.id, :team_id => @team.id)
        @event = Event.create!(:start_at_date => '2012-03-29', :team_id => @team.id)
      end
      
      it "should return false if the member doesn't belong to this team" do
        @membership.delete
        @team.new_availability_for?(@user).should_not be_true
      end
      
      it "should return true if there is unset availability for the passed in member" do
        @team.new_availability_for?(@user).should be_true
      end
      
      it "should return false if there is not unset availability for the passed in member" do
        Availability.create(:membership_id => @membership.id, :event_id => @event.id)
        @team.new_availability_for?(@user).should_not be_true
      end
    end

    it "should have an events method" do
      @team.should respond_to(:events)
    end

    it "should have a users method" do
      @team.should respond_to(:users)
    end

    it "should have a memberships method" do
      @team.should respond_to(:memberships)
    end

    it "should have an account method" do
      @team.should respond_to(:account)
    end    
  end
end
