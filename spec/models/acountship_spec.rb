require 'spec_helper'

describe Accountship do

  before(:each) do
    @account = Factory(:account)
    @user = Factory(:user)
    @accountship = @account.accountships.build(:user_id => @user.id)
  end

  it "should create a new instance given valid attributes" do
    @accountship.save!
  end
  
  describe "validations" do
    
    it "should require an account_id" do
      @accountship.account_id = nil
      @accountship.should_not be_valid
    end
    
    it "should require a user_id" do
      @accountship.user_id = nil
      @accountship.should_not be_valid
    end
  end
  
  describe "accountship methods" do
    
    before(:each) do
      @accountship.save
    end
    
    it "should have a user method" do
      @accountship.should respond_to(:user)
    end
    
    it "should be the correct user" do
      @accountship.user.should == @user
    end
    
    it "should have an account method" do
      @accountship.should respond_to(:account)
    end
    
    it "should be the correct account" do
      @accountship.account.should == @account
    end
    
    describe "admin" do
      
      it "should have an admin method" do
        @accountship.should respond_to(:admin)
      end
      
      it "should not be an admin by default" do
        @accountship.should_not be_admin
      end
      
      it "should be convertible to an admin" do
        @accountship.should be_nil
      end
    end
  end
end