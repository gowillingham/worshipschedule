require 'spec_helper'

describe Skill do
  before(:each) do
    @account = Factory(:account)
    @team = Factory(:team, :account_id => @account.id)
  end
  
  describe "methods" do     
  
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