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
  
  describe "scope" do
    
    describe "active" do
      
      it "should not return inactive users" do
        user = Factory(:user, :email => Factory.next(:email))
        @account.users << user
        membership = @team.memberships.create(:user_id => user.id)
        Membership.active.count.should eq(2)
        
        membership.update_attribute(:active, false)
        Membership.count.should eq(2)
        Membership.active.count.should eq(1)
      end
    end
    
    describe 'admin' do
      
      it "should return only admin users" do
        user = Factory(:user, :email => Factory.next(:email))
        @account.users << user
        membership = @team.memberships.create(:user_id => user.id)
        
        Membership.count.should eq(2)
        Membership.admin.count.should eq(0)
        
        membership.update_attribute(:admin, true)
        Membership.admin.count.should eq(1)
      end
    end
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
