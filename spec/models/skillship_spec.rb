require 'spec_helper'

describe Skillship do
  
  before(:each) do
    @account = Factory(:account)
    @team = Factory(:team, :account_id => @account.id)
    @user = Factory(:user, :email => Factory.next(:email))
    @membership = @team.memberships.create(:user_id => @user.id, :admin => false)
    @skill = @team.skills.create(:name => 'New skill')    
  end
  
  describe "validation" do
    
    before(:each) do
      @attr = {
        :skill_id => @skill.id,
        :membership_id => @membership.id
      }
    end
    
    it "should create a skillship" do
      lambda do
        Skillship.create!(@attr)
      end.should change(Skillship, :count).by(1)
    end

    it "should not create a skillship without a skill_id" do
      lambda do
        skillship = Skillship.create(@attr.merge(:skill_id => nil)) 
      end.should_not change(Skillship, :count).by(1)
    end

    it "should not create a skillship without a membership_id" do
      lambda do
        skillship = Skillship.create(@attr.merge(:membership_id => nil))
      end.should_not change(Skillship, :count).by(1)
    end

  end
  
  describe "methods include" do
    
    it "a membership method" do
      skillship = @membership.skillships.create(:skill_id => @skill.id)
      skillship.should respond_to(:membership)
    end
  
    it "a skill method" do
      skillship = @skill.skillships.create(:membership_id => @membership.id)
      skillship.should respond_to(:skill)
    end
    
    it "a slots method" do
      skillship = @skill.skillships.create(:membership_id => @membership.id)
      skillship.should respond_to(:slots)
    end
  end
end