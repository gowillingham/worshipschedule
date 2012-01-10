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
