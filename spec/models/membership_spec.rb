require 'spec_helper'

describe Membership do
  
  before(:each) do
    @account = Factory(:account)
    @team = Factory(:team, :account_id => @account.id)
    @user = Factory(:user, :email => Factory.next(:email))
    
    @attr = {
      :team_id => @team.id,
      :user_id => @user.id
    }
    
    @membership = Membership.create(:team_id => @team.id, :user_id => @user.id)
  end
  
  describe "methods" do
  
    it "should include user" do
      @membership.should respond_to(:user)
    end
  
    it "should include team" do
      @membership.should respond_to(:team)
    end
    
    it "should include skillships" do
      @membership.should respond_to(:skillships)
    end
    
    it "should include skills" do
      @membership.should respond_to(:skills)
    end
  end
end
