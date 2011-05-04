require 'spec_helper'

describe Account do
  
  before(:each) do
    @attr = { :name => 'Church name' }
  end
  
  it "should create a new instance" do
    Account.create! @attr
  end
  
  describe "owner" do
    it "should have an owner method" do
      owner = Factory(:user)
      account = Account.create!(:name => 'Account name', :owner_id => owner.id)
      account.should respond_to(:owner)
    end
  end
  
  describe "accountships" do
    
    before(:each) do
      @account = Account.create!(@attr)
      @user = Factory(:user)
    end
    
    it "should have an accountships method" do
      @account.should respond_to(:accountships)
    end
    
    it "should have a users method" do
      @account.should respond_to(:users)
    end
  end
end
