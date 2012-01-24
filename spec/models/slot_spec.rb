require 'spec_helper'

describe Slot do
  
  before(:each) do
    @account = Factory(:account)
    @team = Factory(:team, :account_id => @account.id)
    @user = Factory(:user, :email => Factory.next(:email))
    @accountship = @account.accountships.create(:user_id => @user.id)
    @membership = @team.memberships.create(:user_id => @user.id)
  
    @event1 = @team.events.create(:name => "1", :start_at_date => Time.now.strftime("%Y-%m-%d"))
    @event2 = @team.events.create(:name => "2", :start_at_date => Time.now.strftime("%Y-%m-%d"))
    @event3 = @team.events.create(:name => "3", :start_at_date => Time.now.strftime("%Y-%m-%d"))
  
    @skill1 = @team.skills.create(:name => 'Skill1')
    @skill2 = @team.skills.create(:name => 'Skill2')
    @skill3 = @team.skills.create(:name => 'Skill3')
  
    @skillship1 = @membership.skillships.create(:skill_id => @skill1.id)
    @skillship2 = @membership.skillships.create(:skill_id => @skill2.id)
    @skillship3 = @membership.skillships.create(:skill_id => @skill3.id)
    
    @slot = Slot.create!(:event_id => @event1.id, :skillship_id => @skillship1.id)
  end
  
  describe "methods" do
    
    it "should respond to event" do
      @slot.should respond_to(:event)
    end
    
    it "should respond to skillship" do
      @slot.should respond_to(:skillship)
    end 
  end
end