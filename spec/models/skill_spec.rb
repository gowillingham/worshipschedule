require 'spec_helper'

describe Skill do
  before(:each) do
    @account = Factory(:account)
    @team = Factory(:team, :account_id => @account.id)
  end
  
  describe "method(s)" do     
  
    it "should include team" do
      skill = @team.skills.create(:name => 'new skill')
      skill.should respond_to(:team)
    end
    
    it "should include skillships" do
      skill = @team.skills.create(:name => 'new skill')
      skill.should respond_to(:skillships)
    end
    
    it "should include memberships" do
      skill = @team.skills.create(:name => 'new skill')
      skill.should respond_to(:memberships)
    end
    
    it "should include assign_skillships" do
      skill = @team.skills.create(:name => 'new skill')
      skill.should respond_to(:assign_skillships)      
    end
    
    describe "assign_skillships" do
      
      it "should accept a list of membership_ids and update the skillships" do
        skill = @team.skills.create(:name => 'New skill')
        user_1 = Factory(:user, :email => Factory.next(:email))
        user_2 = Factory(:user, :email => Factory.next(:email))
        user_3 = Factory(:user, :email => Factory.next(:email))
        
        @account.users << user_1 << user_2 << user_3
        membership_1 = @team.memberships.create(:user_id => user_1.id)
        membership_2 = @team.memberships.create(:user_id => user_2.id)
        membership_3 = @team.memberships.create(:user_id => user_3.id)  
        
        skill.skillships.create(:membership_id => membership_2.id)
        
        lambda do 
          skill.assign_skillships([membership_1.id, membership_3.id]) 
        end.should change(Skillship, :count).by(1)
      end
    end
  end
  
  it "should require a name" do   
    skill = @team.skills.new()
    skill.should_not be_valid
  end
  
  it "should require a team_id" do  
    skill = Skill.new(:name => 'Skill name')
    skill.should_not be_valid
  end
end