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
  
  it "should have a users method" do
    @membership.should respond_to(:user)
  end
  
  it "should have a teams method" do
    @membership.should respond_to(:team)
  end
end
