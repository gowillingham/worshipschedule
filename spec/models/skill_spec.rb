require 'spec_helper'

describe Skill do
  before(:each) do
    @account = Factory(:account)
    @team = Factory(:team, :account_id => @account.id)
  end
  
  it "should require a name" do   
    skill = @team.skills.new()
    skill.should_not be_valid
  end
  
  it "should require a team_id" do  
    skill = Skill.new(:name => 'Skill name')
    skill.should_not be_valid
  end
  
  it "should have a team method" do
    skill = @team.skills.create(:name => 'new skill')
    skill.should respond_to(:team)
  end
end