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
  
  it "should have an account method" do
    @team.should respond_to(:account)
  end
end
